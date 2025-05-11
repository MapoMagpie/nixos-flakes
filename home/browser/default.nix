{ config, ... }:
{
  home.file.".mozilla/firefox/mapomagpie/chrome" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/browser/firefox-compact-ui";
  };
  programs.firefox = {
    enable = true;
    profiles.mapomagpie = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.search.openintab" = true;
        "browser.urlbar.openintab" = true;
        "browser.tabs.loadBookmarksInTabs" = true;
        "browser.tabs.closeWindowWithLastTab" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "browser.tabs.allow_transparent_browser" = true;
      };
    };
  };
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
    ];
  };
}
