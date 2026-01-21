typeset -U path cdpath fpath manpath
for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

HELPDIR="/nix/store/309lg0w4dj1nbcr04pwzzkhvisfnmqqn-zsh-5.9/share/zsh/$ZSH_VERSION/help"

autoload -U compinit && compinit
source /nix/store/gnypi757i5gv9db1nq9579r24m1f3zmd-zsh-autosuggestions-0.7.1/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history)


eval "$(/nix/store/ng34qgwm1impjlsvmqam6329xchjz6ss-zoxide-0.9.8/bin/zoxide init zsh )"

# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="100000"
SAVEHIST="100000"

HISTFILE="/home/mapomagpie/.local/share/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK

# Enabled history options
enabled_opts=(
  EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_IGNORE_SPACE
  SHARE_HISTORY
)
for opt in "${enabled_opts[@]}"; do
  setopt "$opt"
done
unset opt enabled_opts

# Disabled history options
disabled_opts=(
  APPEND_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS
)
for opt in "${disabled_opts[@]}"; do
  unsetopt "$opt"
done
unset opt disabled_opts

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line
source /home/mapomagpie/nixos/home/misc/scripts/yazi_cwd.sh
source /nix/store/r85nn3rvvqzxkys5kxki5hf8vhp1kcl5-skim-0.20.5/share/skim/completion.zsh
source /nix/store/r85nn3rvvqzxkys5kxki5hf8vhp1kcl5-skim-0.20.5/share/skim/key-bindings.zsh
nd() {
  if [ -z "$1" ]; then
    nix develop -c zsh
  else
    nix develop ~/nixos#"$1" -c zsh
  fi
}

if [[ $TERM != "dumb" ]]; then
  eval "$(starship init zsh)"
fi

if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="no-rc no-cursor"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

alias -- bos='sudo nixos-rebuild switch --flake ~/nixos && notify-send '\''nixos build succeeded'\'''
alias -- h='hx .'
alias -- kt='SHELL=zsh kitty --detach'
alias -- ll='eza -l'
alias -- nu='nix flake update'
alias -- y=yazi_cwd
source /nix/store/mrqy0vwbh1p0raclnw2sjbmpjs1zpc91-zsh-syntax-highlighting-0.8.0/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS+=()


