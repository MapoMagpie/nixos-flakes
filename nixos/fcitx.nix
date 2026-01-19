{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-nord
        kdePackages.fcitx5-configtool
        catppuccin-fcitx5
        fcitx5-tokyonight
        kdePackages.fcitx5-qt
      ];
      settings = {
        globalOptions = {
          "Hotkey" = {
            "TriggerKeys" = "Shift+Shift_R";
            "EnumerateWithTriggerKeys" = "True";
            "ActivateKeys" = "";
            "DeactivateKeys" = "";
            "AltTriggerKeys" = "Shift+Shift_R";
            "EnumerateForwardKeys" = "Shift+Shift_R";
            "EnumerateBackwardKeys" = "";
            "EnumerateSkipFirst" = "False";
            "EnumerateGroupForwardKeys" = "";
            "EnumerateGroupBackwardKeys" = "";
            "TogglePreedit" = "";
            "PrevPage" = "Up";
            "NextPage" = "Down";
            "PrevCandidate" = "";
            "NextCandidate" = "";
            "ModifierOnlyKeyTimeout" = "250";
          };
          "Behavior" = {
            # Active By Default
            "ActiveByDefault" = "True";
            # Reset state on Focus In
            "resetStateWhenFocusIn" = "Program";
            # Share Input State
            "ShareInputState" = "All";
            # Show preedit in application
            "PreeditEnabledByDefault" = "True";
            # Show Input Method Information when switch input method
            "ShowInputMethodInformation" = "True";
            # Show Input Method Information when changing focus
            "showInputMethodInformationWhenFocusIn" = "True";
            # Show compact input method information
            "CompactInputMethodInformation" = "False";
            # Show first input method information
            "ShowFirstInputMethodInformation" = "True";
            # Default page size
            "DefaultPageSize" = "5";
            # Override XKB Option
            "OverrideXkbOption" = "False";
            # Custom XKB Option
            "CustomXkbOption" = "";
            # Force Enabled Addons
            "EnabledAddons" = "";
            # Force Disabled Addons
            "DisabledAddons" = "";
            # Preload input method to be used by default
            "PreloadInputMethod" = "True";
            # Allow input method in the password field
            "AllowInputMethodForPassword" = "False";
            # Show preedit text when typing password
            "ShowPreeditForPassword" = "False";
            # Interval of saving user data in minutes
            "AutoSavePeriod" = "30";

          };
        };
        inputMethod = {
          "Groups/0" = {
            "Name" = "Default";
            "Default Layout" = "us";
            "DefaultIM" = "keyboard-us";
          };
          "Groups/0/Items/1" = {
            "Name" = "keyboard-us";
            "Layout" = "";
          };
          "Groups/0/Items/0" = {
            "Name" = "rime";
            "Layout" = "";
          };
          "GroupOrder" = {
            "0" = "Default";
          };
        };
        # addons = {
        #   pinyin.globalSection.EmojiEnabled = "True";
        # };
        addons = {
          classicui.globalSection = {
            "Vertical Candidate List" = "True";
            "WheelForPaging" = "False";
            "Font" = "LXGW WenKai Mono Medium 16";
            "MenuFont" = "Noto Serif CJK SC 10";
            "TrayFont" = "Noto Serif CJK SC 10";
            "TrayOutlineColor" = "#000000";
            "TrayTextColor" = "#ffffff";
            "PreferTextIcon" = "Flase";
            "ShowLayoutNameInIcon" = "True";
            "UseInputMethodLanguageToDisplayText" = "True";
            "Theme" = "catppuccin-frappe-yellow";
            "DarkTheme" = "catppuccin-frappe-yellow";
            "UseDarkTheme" = "True";
            "UseAccentColor" = "False";
            "PerScreenDPI" = "False";
            "ForceWaylandDPI" = "0";
            "EnableFractionalScale" = "True";
          };
          rime.globalSection = {
            "PreeditMode " = "Commit preview";
            "InputState" = "Follow Global Configuration";
            "PreeditCursorPositionAtBeginning" = "True";
            "SwitchInputMethodBehavior" = "Commit commit preview";
            "Deploy" = "";
            "Synchronize" = "";
          };
        };
      };
    };
  };
}
