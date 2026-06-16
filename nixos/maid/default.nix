{ pkgs, host, ... }:
{
  file.home.".zshrc".text = ''
    eval "$(${pkgs.starship}/bin/starship init zsh)"
    eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
  '';
  file.xdg_config = {
    "git/config".text = ''
      [user]
      	name = "${host.git.userName}"
      	email = "${host.git.userEmail}"
    '';

    "yazi".source = "{{home}}/nixos/home/yazi";
    "kitty".source = "{{home}}/nixos/home/kitty";
    "starship.toml".source = "{{home}}/nixos/home/starship/starship.toml";
    "television/config.toml".source = "{{home}}/nixos/home/television/config.toml";
    "television/cable/files.toml".source = "{{home}}/nixos/home/television/cable/files.toml";

    "helix".source = "{{home}}/nixos/home/helix";
  };

  packages = with pkgs; [
    zoxide
    starship

    nixd
    nixfmt

    gitui
    yt-dlp
    kitty
  ];
}
