{ pkgs, ... }:
let
  # Find this info at https://tableplus.com/blog/2020/01/changelogs-linux.html.
  version = "1.5.5";
  build-number = "300";
  pname = "tableplus";
  src = pkgs.fetchurl {
    url = "https://files.tableplus.com/linux/x64/${build-number}/TablePlus-x64.AppImage";
    # This will change when build numbers change.
    hash = "sha256-MKoXxTZOWenhfyYUYT9FU8hAMf4IhtR1w4RADJlxGu8=";
  };
  contents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.adwaita-icon-theme ];

  extraInstallCommands = ''
    install -m 444 -D ${contents}/${pname}-appimage.desktop -t $out/share/applications
    cp -r ${contents}/usr/share/icons $out/share
  '';
}
