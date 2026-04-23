{
  description = "Home Manager configuration of stephen";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
       url = "github:nix-community/nix-index-database";
       inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nix-index-database, home-manager, zen-browser, nixpkgs-stable, noctalia, ... }@inputs:
  let
    system = "x86_64-linux";
allowedUnfree = [
      "amp-cli"
      "anki-bin"
      "codex"
      "discord"
      "dropbox"
      "etlegacy"
      "etlegacy-assets"
      "fastmail-desktop"
      "firefox-bin"
      "firefox-bin-unwrapped"
      "slack"
      "spotify"
      "todoist-electron"
      "vscode-extension-vadimcn-vscode-lldb"
    ];
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
      overlays = [
        (final: prev: {
          zen = zen-browser.packages.${system}.default;
        })
      ];
    };
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
        "claude-code"
      ];
    };
  in
  {
    homeConfigurations."stephen" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        nix-index-database.homeModules.default
        noctalia.homeModules.default
        ./noctalia.nix
        {
          home.username = "stephen";
          home.homeDirectory = "/home/stephen";
          home.stateVersion = "25.05";

          home.packages = with pkgs; [
            aerc
            akkuPackages.scheme-langserver
            algol68g
            amp-cli
            anki-bin
            bzflag
            chez
            cliphist
            cmatrix
            codex
            csvkit
            darkman
            dict
            dig
            discord
            djbdns
            dmidecode
            dropbox
            easyeffects
            eksctl
            emmylua-ls
            etlegacy
            etlegacy-assets
            eww
            exercism
            exiftool
            evtest
            #fastfetch
            fastmail-desktop
            firefox-bin-unwrapped
            fd
            fractal
            geoclue2
            ghostty
            git-filter-repo
            git-open
            gnuplot_qt
            grim
            hyprland
            hyprlauncher
            hyprlock
            imagemagick
            iw
            jjui
            lazyjj
            jujutsu
            delta
            difftastic
            kubeaudit
            kubetui
            kube-bench
            kube-linter
            kubectl-graph
            lazygit
            lf
            libnotify
            libqalculate
            librespot
            librsvg # for mdmath.nvim
            lsof
            lua
            lua-language-server
            mako
            ncspot
            nixd
            nmap
            nodejs_24
            #ollama-vulkan
            openssl
            peaclock
            playerctl
            psmisc
            pdf4qt
            swi-prolog
            #reaper
            ripgrep
            rpi-imager
            rustlings
            slack
            spotify
            signal-desktop
            slurp
            swaybg
            swayidle
            swayimg
            swaylock
            syncthing
            telegram-desktop
            timer
            tree-sitter
            (texlive.combine {
            inherit (texlive) scheme-medium
              collection-langenglish
              collection-mathscience
              collection-bibtexextra
              collection-latexextra
              collection-fontsrecommended
              dvisvgm;   # for SVG previews in some viewers
            })
            latexrun
            todoist-electron
            vscode-extensions.vadimcn.vscode-lldb
            yq
            wev
            wf-recorder
            whois
            zen
            zip
            zoxide
            (import ./custom_derivations/tableplus.nix { inherit pkgs; })
          ] ++ [
            pkgs-stable.awscli2
            pkgs-stable.spotify-player
            pkgs-stable.libreoffice
            pkgs-stable.claude-code
          ];

          programs = {
            home-manager.enable = true;
            btop.enable = true;
            chromium.enable = true;
            gh.enable = true;
            mpv.enable = true;
            zathura.enable = true;
            direnv = {
              enable = true;
              enableZshIntegration = true;
              nix-direnv.enable = true;
              config = {
                global = {
                  hide_env_diff = true;
                };
              };
            };
          };

          xdg.mimeApps = {
            enable = true;
            defaultApplications = let
              defaultBrowser = "zen-beta.desktop";
            in
            {
              "image/png" = "swayimg.desktop";
              "image/jpg" = "swayimg.desktop";
              "image/jpeg" = "swayimg.desktop";
              "application/pdf" = "org.pwmt.zathura.desktop";
              "x-scheme-handler/http" = "${defaultBrowser}";
              "x-scheme-handler/https" = "${defaultBrowser}";
              "x-scheme-handler/chrome" = "${defaultBrowser}";
              "application/x-extension-htm" = "${defaultBrowser}";
              "application/x-extension-html" = "${defaultBrowser}";
              "application/x-extension-shtml" = "${defaultBrowser}";
              "application/x-extension-xhtml" = "${defaultBrowser}";
              "application/x-extension-xht" = "${defaultBrowser}";
              "application/xhtml+xml" = "${defaultBrowser}";
              "text/html" = "${defaultBrowser}";
              "x-scheme-handler/sgnl" = "signal.desktop";
              "x-scheme-handler/signalcaptcha" = "signal.desktop";
              "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
              "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
            };
          };

          services = {
            darkman.enable = true;
            easyeffects.enable = true;
          };


        }
      ];
    };
  };
}
