{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
  ];
  home.file.".config/helix/themes".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/code/helix/themes";
  programs.helix = {
    enable = true;
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "nixfmt";
            args = [ "--width=300" ];
          };
        }
        {
          name = "typescript";
          auto-format = true;
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }
      ];
    };
    settings = {
      theme = "catppuccin_mocha_nb";
      keys.insert = {
        "esc" = [
          ":run-shell-command ~/nixos/home/misc/scripts/setrimeasciimode.sh true"
          "normal_mode"
        ];
        "C-s" = ":w";
      };
      keys.normal = {
        "esc" = [ ":run-shell-command ~/nixos/home/misc/scripts/setrimeasciimode.sh true" ];
        "C-s" = ":w";
      };
      editor = {
        auto-format = true;
        mouse = true;
        # line-number = "relative";
        # cursorline = true;
        completion-timeout = 250;
        # completion-trigger-len = 2;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker = {
          # hidden = false;
          git-ignore = true;
        };
        terminal.command = "kitty";
        # soft-wrap = {
        #   enable = false;
        #   max-wrap = 5; # increase value to reduce forced mid-word wrapping
        #   max-indent-retain = 2;
        #   wrap-indicator = "";
        # };
        whitespace.render = {
          space = "none";
          tab = "all";
          nbsp = "all";
          nnbsp = "all";
          newline = "all";
        };
        whitespace.characters = {
          space = "·";
          nbsp = "⍽";
          nnbsp = "␣";
          tab = "→";
          newline = "⏎";
          # Tabs will look like "→···" (depending on tab width);
          tabpad = "·";
        };
      };
    };
  };
}
