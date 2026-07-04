{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    config = {
      niri = {
        # "org.freedesktop.impl.portal.Notification" = "gnome";
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        # "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
    };
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
  };
}
