#!/usr/bin/env bash
# shell_prompt.sh - Generate a pretty prompt line similar to starship

output=""

# --- 1. Yazi ---
if [[ -n "${YAZI_ID:-}" ]]; then
    output+="\e[01;05;33mỲḁ\e[0m "
fi

# --- 2. Jobs ---
# `jobs` is a bash builtin, so this script only ever sees its own (empty) job
# table, never the interactive shell's. Two mechanisms instead:
#   1. SHELL_JOB_COUNT env var — the exact `jobs -p | wc -l` of the parent
#      shell, if the shell exports it. Optional hook in ~/.bashrc:
#        PROMPT_COMMAND="history -a; export SHELL_JOB_COUNT=\$(jobs -p | wc -l); \$PROMPT_COMMAND"
#   2. Process inspection fallback (works right now, no rc change needed):
#      flyline forks widget commands directly from the shell, so $PPID is the
#      interactive bash. With job control on, every background job is a child
#      of the shell in its own process group (a pipeline shares one pgrp and
#      counts as one job; stopped jobs show state T; finished jobs are reaped
#      or filtered as zombies). So: count the distinct non-zombie children of
#      $PPID whose pgrp differs from the shell's own pgrp — that is the number
#      of background jobs. (Disowned jobs are still counted, unlike `jobs`.)
jobs_count=0
if [[ "${SHELL_JOB_COUNT:-}" =~ ^[0-9]+$ ]]; then
    jobs_count=$SHELL_JOB_COUNT
elif command -v ps >/dev/null 2>&1; then
    shell_pgid=$(ps -o pgid= -p "$PPID" 2>/dev/null | tr -d ' ')
    if [[ -n "$shell_pgid" ]]; then
        jobs_count=$(ps -o pid=,pgid=,stat= --ppid "$PPID" 2>/dev/null |
            awk -v me=$$ -v spg="$shell_pgid" \
                '$1 != me && $3 !~ /^Z/ && $2 != "" && $2 != spg { print $2 }' |
            sort -u | wc -l)
        jobs_count=${jobs_count// /}
    fi
fi
if [[ "$jobs_count" -gt 0 ]]; then
    output+="\e[01;05;93mᐇ\e[0m "
fi

# --- 3. Git ---
# Use a single `git status -s -b` call for branch, upstream, ahead/behind,
# and all file change counts. Only stash + in-progress ops need extra checks.
if status_out=$(git status -s -b 2>/dev/null) && [[ -n "$status_out" ]]; then
    git_dir=$(git rev-parse --git-dir 2>/dev/null)

    # --- Parse branch line (first line of status_out) ---
    branch_line="${status_out%%$'\n'*}"
    branch_line="${branch_line#\#\# }"

    # Detached HEAD: "HEAD (no branch)" or "HEAD (no branch)..."
    if [[ "$branch_line" == "HEAD (no branch)"* ]]; then
        branch=":$(git rev-parse --short HEAD 2>/dev/null)"
    # No commits yet
    elif [[ "$branch_line" == "No commits yet on "* ]]; then
        branch="${branch_line#No commits yet on }"
    else
        # Normal branch, possibly with upstream tracking: "main...origin/main [ahead N]"
        if [[ "$branch_line" == *...* ]]; then
            branch="${branch_line%%...*}"
            tail="${branch_line#*...}"
            # tail is e.g. "origin/main [ahead 2]" or "origin/main [ahead 1, behind 3]"
            if [[ "$tail" =~ ahead\ ([0-9]+) ]]; then
                ahead="${BASH_REMATCH[1]}"
            fi
            if [[ "$tail" =~ behind\ ([0-9]+) ]]; then
                behind="${BASH_REMATCH[1]}"
            fi
        else
            # No upstream: "main"
            branch="${branch_line%% *}"
        fi
    fi

    # --- Parse file status lines (skip first line) ---
    file_lines="${status_out#*$'\n'}"
    file_codes=$(echo "$file_lines" | cut -c1-2)

    total_modified=$(echo "$file_codes" | grep -c 'M')
    total_added=$(echo "$file_codes" | grep -cE '^A|^\?\?')
    total_deleted=$(echo "$file_codes" | grep -c 'D')

    # Build changes string
    changes=""
    [[ $total_modified -gt 0 ]] && changes+="=${total_modified}"
    [[ $total_added -gt 0 ]] && changes+="+${total_added}"
    [[ $total_deleted -gt 0 ]] && changes+="-${total_deleted}"

    # --- State ---
    state=""

    # In-progress operations (fast filesystem checks)
    if [[ -f "$git_dir/MERGE_HEAD" ]] ||
       [[ -d "$git_dir/rebase-merge" ]] ||
       [[ -d "$git_dir/rebase-apply" ]] ||
       [[ -f "$git_dir/CHERRY_PICK_HEAD" ]] ||
       [[ -f "$git_dir/BISECT_LOG" ]] ||
       [[ -f "$git_dir/REVERT_HEAD" ]]; then
        state+="≡"
    fi

    # Conflicts (detect from status codes)
    if echo "$file_codes" | grep -qE '^UU|^AA|^DD'; then
        state+="✘"
    fi

    # Ahead/behind (parsed from branch line above)
    if [[ -n "${ahead:-}" ]] && [[ -n "${behind:-}" ]]; then
        state+="⇕"
    elif [[ -n "${ahead:-}" ]]; then
        state+="⇡"
    elif [[ -n "${behind:-}" ]]; then
        state+="⇣"
    fi

    # Stashes
    stash_count=$(git stash list 2>/dev/null | wc -l)
    stash_count=${stash_count// /}
    if [[ $stash_count -gt 0 ]]; then
        state+="↩${stash_count}"
    fi

    output+="\e[01;36m⨚${branch}"
    [[ -n "$changes" ]] && output+="\e[31m${changes}\e[36m"
    [[ -n "$state" ]] && output+="${state}"
    output+="\e[0m "
fi

# --- 4. Nix shell ---
if [[ -n "${IN_NIX_SHELL:-}" ]]; then
    output+="\e[01;34mṄịᶍ\e[0m"
    [[ -n "${name:-}" ]] && output+="\e[02;37m[${name}]"
    output+="\e[00m "
fi

# Trim trailing space and print
output="${output% }"
echo -e "$output"
