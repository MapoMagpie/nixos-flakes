{ ... }:
{
  programs.bash = {
    enable = true;
    completion.enable = false;
    # interactiveShellInit = ''
    #   enable -f ${pkgs.flyline}/lib/libflyline.so flyline
    # '';
  };
}
