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
      shojiwm = {
        # "org.freedesktop.impl.portal.Notification" = "gnome";
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        # "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
    };
    # Routes every xdg-open through the XDG Desktop Portal. That breaks
    # xdg-mime handling for plain files: the portal shows an app chooser and
    # ignores the registered default (and hides NoDisplay apps like swayimg).
    # Disabled so xdg-open/yazi use the xdg-mime default directly.
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
  };
}
