#!/usr/bin/env bash
# shell_prompt.sh - Generate a pretty prompt line similar to starship
# Outputs: 🆈 | git branch A{M}D{...} state | 🆁 version | ❄️

output=""

# --- 1. Yazi ---
if [[ -n "${YAZI_ID:-}" ]]; then
    output+="\e[01;33m[Ỳḁ]\e[0m "
fi

# --- 2. Jobs ---
# When sourced, use jobs builtin for accuracy.
# When executed (e.g. via $(...) in PS1), fall back to ps via $PPID.
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    # Sourced — use shell builtin
    if [[ -n "$(jobs -p)" ]]; then
        output+="\e[1;93m[ᐇ]\e[0m "
    fi
else
    # Executed as subprocess — check parent shell's child processes
    # Exclude ourselves ($$) to avoid false positive
    if pgrep -P "$PPID" 2>/dev/null | grep -qvx "$$"; then
        output+="\e[1;93m[ᐇ]\e[0m "
    fi
fi

# --- 3. Git ---
if git rev-parse --git-dir &>/dev/null; then
    git_dir=$(git rev-parse --git-dir 2>/dev/null)

    # Branch name (detached HEAD → short commit hash prefixed with :)
    branch=$(git branch --show-current 2>/dev/null)
    if [[ -z "$branch" ]]; then
        branch=":$(git rev-parse --short HEAD 2>/dev/null)"
    fi

    # File change counts (staged + unstaged)
    staged_added=$(git diff --cached --name-only --diff-filter=A 2>/dev/null | wc -l)
    staged_modified=$(git diff --cached --name-only --diff-filter=M 2>/dev/null | wc -l)
    staged_deleted=$(git diff --cached --name-only --diff-filter=D 2>/dev/null | wc -l)

    unstaged_modified=$(git diff --name-only --diff-filter=M 2>/dev/null | wc -l)
    unstaged_deleted=$(git diff --name-only --diff-filter=D 2>/dev/null | wc -l)
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)

    # Trim whitespace from wc -l output
    staged_added=${staged_added// /}
    staged_modified=${staged_modified// /}
    staged_deleted=${staged_deleted// /}
    unstaged_modified=${unstaged_modified// /}
    unstaged_deleted=${unstaged_deleted// /}
    untracked=${untracked// /}

    total_added=$((staged_added + untracked))
    total_modified=$((staged_modified + unstaged_modified))
    total_deleted=$((staged_deleted + unstaged_deleted))

    # Build changes string: A{N}M{N}D{N} (only non-zero)
    changes=""
    [[ $total_modified -gt 0 ]] && changes+="=${total_modified}"
    [[ $total_added -gt 0 ]] && changes+="+${total_added}"
    [[ $total_deleted -gt 0 ]] && changes+="-${total_deleted}"

    # --- State ---
    state=""

    # In-progress operations (merge, rebase, cherry-pick, bisect)
    if [[ -f "$git_dir/MERGE_HEAD" ]] ||
       [[ -d "$git_dir/rebase-merge" ]] ||
       [[ -d "$git_dir/rebase-apply" ]] ||
       [[ -f "$git_dir/CHERRY_PICK_HEAD" ]] ||
       [[ -f "$git_dir/BISECT_LOG" ]]; then
        state+="≡"
    fi

    # Conflicts
    if git status --porcelain 2>/dev/null | grep -q '^UU\|^AA\|^DD'; then
        state+="✘"
    fi

    # Ahead/behind upstream
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [[ -n "$upstream" ]]; then
        ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
        behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
        if [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]; then
            state+="⇕"
        elif [[ $ahead -gt 0 ]]; then
            state+="⇡"
        elif [[ $behind -gt 0 ]]; then
            state+="⇣"
        fi
    fi

    # Stashes
    stash_count=$(git stash list 2>/dev/null | wc -l)
    stash_count=${stash_count// /}
    if [[ $stash_count -gt 0 ]]; then
        state+="↩${stash_count}"
    fi

    output+="\e[01;36m⨚${branch}"
    [[ -n "$changes" ]] && output+=" \e[31m${changes}\e[36m"
    [[ -n "$state" ]] && output+=" ${state}"
    output+="\e[0m "
fi

# --- 4. Nix shell ---
if [[ -n "${IN_NIX_SHELL:-}" ]]; then
    output+="\e[01;34mṄịᶍ\e[02;37m"
    [[ -n "${name:-}" ]] && output+=" ${name}"
    output+="\e[00m "
fi

# Trim trailing space and print
output="${output% }"
echo -e "$output"
