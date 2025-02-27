
#!/bin/sh

awk -v RS= '{
    id = ""; title = ""; app = ""; workspace = ""
    n = split($0, lines, /\n/)
    for (i = 1; i <= n; i++) {
        line = lines[i]
        if (line ~ /^Window ID [0-9]+/) {
            id = line
            sub(/^Window ID /, "", id)
            sub(/:.*/, "", id)
        }
        else if (line ~ /^  Title: "/) {
            title = line
            sub(/^  Title: "/, "", title)
            sub(/".*$/, "", title)
        }
        else if (line ~ /^  App ID: "/) {
            app = line
            sub(/^  App ID: "/, "", app)
            sub(/".*$/, "", app)
        }
        else if (line ~ /^  Workspace ID: [0-9]+/) {
            workspace = line
            sub(/^  Workspace ID: /, "", workspace)
            sub(/[^0-9].*$/, "", workspace)
        }
    }
    if (id && title && app && workspace) {
        printf "%s/%s %s %s\n", id, workspace, title, app
    }
}' "$@"
