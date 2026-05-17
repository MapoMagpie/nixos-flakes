{
  pkgs,
  ...
}:
{

  programs = {
    niri.enable = true;
  };

  environment.systemPackages = with pkgs; [
    imagemagick
    mpv
    amdgpu_top
    showmethekey
    hyprpolkitagent
    libnotify
    wl-clipboard
    grim
    xwayland-satellite
  ];
}
