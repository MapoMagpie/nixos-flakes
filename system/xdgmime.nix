{ ... }:
{
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "image/png" = [ "swayimg.desktop" ];
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/bmp" = [ "swayimg.desktop" ];
      "image/gif" = [ "swayimg.desktop" ];
      "image/webp" = [ "swayimg.desktop" ];
      "image/avif" = [ "swayimg.desktop" ];
      "image/svg+xml" = [ "swayimg.desktop" ];
      "video/*" = [ "mpv.desktop" ];
      "text/*" = [ "helix.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
    };
  };
}
