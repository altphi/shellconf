{
  description = "ncspot 1.3.2 with librespot 0.8.0";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.ncspot = pkgs.rustPlatform.buildRustPackage rec {
          pname   = "ncspot";
          version = "1.3.2";

          src = pkgs.fetchFromGitHub {
            owner = "hrkfdn";
            repo  = "ncspot";
            rev   = "v${version}";
            # placeholder – will be replaced by the error message
            sha256 = "sha256-nmy+KGwGDf3Pp0OHngBqflicASfQOnq81YGaEipv7RE=";
          };

          # placeholder – will be replaced by the error message
          cargoHash = "sha256-XmEiTUKb7ksPxQbjjDG8hZmIM/vJ6nnb30GSJp9F+18=";

          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = with pkgs; [
            openssl
            libpulseaudio
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            alsa-lib
          ];

          meta = with pkgs.lib; {
            description = "ncurses Spotify client written in Rust";
            homepage    = "https://github.com/hrkfdn/ncspot";
            license     = licenses.bsd2;
            mainProgram = "ncspot";
          };
        };

        packages.default = self.packages.${system}.ncspot;
      });
}
