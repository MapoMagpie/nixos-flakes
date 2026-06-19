{
  pkgs,
  ...
}:
{

  programs.niri.enable = true;
  programs.gpu-screen-recorder.enable = true;

  environment.systemPackages = with pkgs; [
    imagemagick
    mpv
    # amdgpu_top
    showmethekey
    hyprpolkitagent
    grim
    xwayland-satellite
  ];
}
