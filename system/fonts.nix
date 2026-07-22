{
  pkgs,
  host,
  # externalFonts,
  ...
}:
{

  # 验证： fc-match "serif:lang=zh" 等命令检查每个族的本地化首选
  environment.systemPackages = [ pkgs.fontforge ];
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Roboto Slab"
          "Nono Serif"
          "LXGW WenKai"
        ];
        sansSerif = [
          "Roboto Flex"
          "Nono Sans"
          "LXGW WenKai Screen"
          "Noto Sans Symbols"
          "Noto Sans Symbols 2"
        ];
        monospace = [
          "Comic Mono"
          "0xProto Nerd Font Mono"
          "LXGW WenKai Mono"
          "Noto Sans Symbols"
          "Noto Sans Symbols 2"
        ];
        emoji = [
          "Noto Color Emoji"
        ];
      };
      # 限制 LXGW WenKai 系列仅参与 CJK 文字渲染，不使用其内嵌的拉丁/西里尔等字形。
      # 原理：在字体扫描阶段将该系列字体的 lang 标记为 zh-cn。
      # fontconfig 匹配时，pattern 的 lang 与字体 lang 越近得分越高。
      #   - 应用请求 lang=zh 的文本 → LXGW 高分命中
      #   - 应用请求 lang=en/不指定 lang 的拉丁文本 → 拉丁字体（Roboto/0xProto/Nerd Font）高分，LXGW 低分
      #   - 混合文本（如 "中文 Hello"），Pango 等引擎按字符 fallback：
      #     拉丁走 Roboto/0xProto，CJK 走 LXGW
      # localConf = ''
      #   <?xml version="1.0"?>
      #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      #   <fontconfig>
      #     <match target="scan">
      #       <test name="family" compare="contains"><string>LXGW WenKai</string></test>
      #       <edit name="lang" mode="assign"><string>zh-cn</string></edit>
      #     </match>
      #   </fontconfig>
      # '';
    };
    packages =
      with pkgs;
      [
        roboto-slab # bold serif
        roboto-flex # sans serif
        roboto-mono
        roboto-serif
        nerd-fonts._0xproto
        lxgw-wenkai
        lxgw-neoxihei
        lxgw-wenkai-tc
        lxgw-fusionkai
        lxgw-wenkai-screen
        noto-fonts
        noto-fonts-color-emoji
        comic-mono # Legible monospace font that looks like Comic Sans.
      ]
      ++ (
        if host.enable_ui then
          [
            # externalFonts.default
          ]
        else
          [ ]
      );
    enableDefaultPackages = false;
    fontDir.enable = true;
  };
}
