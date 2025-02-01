{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
    # rust-analyzer
  ];
  home.file.".config/helix/themes" = {
    source = config.lib.file.mkOutOfStoreSymlink ./helix/themes;
  };
  home.file.".config/helix/setrimeasciimode.sh" = {
    source = config.lib.file.mkOutOfStoreSymlink ./helix/setrimeasciimode.sh;
  };
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
      # language-server = {
      #   denolsp = {
      #     command = "${pkgs.deno}/bin/deno";
      #     args = [ "lsp" ];
      #     environment.NO_COLOR = "1";
      #     config.deno = {
      #       enable = true;
      #       lint = true;
      #       unstable = true;
      #       suggest = {
      #         completeFunctionCalls = false;
      #         imports = {
      #           hosts."https://deno.land" = true;
      #         };
      #       };
      #       inlayHints = {
      #         enumMemberValues.enabled = true;
      #         functionLikeReturnTypes.enabled = true;
      #         parameterNames.enabled = "all";
      #         parameterTypes.enabled = true;
      #         propertyDeclarationTypes.enabled = true;
      #         variableTypes.enabled = true;
      #       };
      #     };
      #   };
      # };
    };
    settings = {
      theme = "catppuccin_mocha_nb";
      keys.insert = {
        "esc" = [
          ":run-shell-command ~/.config/helix/setrimeasciimode.sh"
          "normal_mode"
        ];
        "C-s" = ":w";
      };
      keys.normal = {
        "esc" = [ ":run-shell-command ~/.config/helix/setrimeasciimode.sh" ];
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
        terminal.command = "ghostty";
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
