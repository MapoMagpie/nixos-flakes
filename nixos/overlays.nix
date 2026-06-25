{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      github-copilot-cli =
        super.callPackage
          # 直接从 PR 的 raw 文件拉取（干净且可维护）
          (import (
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/misumisumi/nixpkgs/update-github-copilot-cli/pkgs/by-name/gi/github-copilot-cli/package.nix";
              sha256 = "sha256:0napspj04pwh6vlgrwsif7plab49ckjpqhlbr7r7qkrgqaqzz53w"; # 先随便填，构建时 Nix 会报错并给出正确 hash
            }
          ))
          { };
    })
  ];
}
