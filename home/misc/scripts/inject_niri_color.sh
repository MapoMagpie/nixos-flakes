#!/etc/profiles/per-user/mapomagpie/bin/zsh
sd '^\s+active-color ".*?".*' "$(rg -N 'active-color' ~/nixos/home/ui/niri/colors.txt)" ~/nixos/home/ui/niri/config.kdl
sd '^\s+insert-hint \{ color ".*?"; \}' "$(rg -N 'insert-hint' ~/nixos/home/ui/niri/colors.txt)" ~/nixos/home/ui/niri/config.kdl
sd '^\s+backdrop-color ".*?".*' "$(rg -N 'backdrop-color' ~/nixos/home/ui/niri/colors.txt)" ~/nixos/home/ui/niri/config.kdl
