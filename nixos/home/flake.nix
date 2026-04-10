{
  description = "Home Manager configuration of stephen";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # quickshell = {
    #   url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # ncspot-flake.url = "path:/home/stephen/nixos/home/custom_flakes/ncspot";
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, nixpkgs-stable, ... }@inputs:
  let
    system = "x86_64-linux";
    secrets = if builtins.pathExists ./secrets.nix
      then import ./secrets.nix
      else { location = { lat = 0.0; lng = 0.0; }; sshKeyPath = ""; vpnScriptPath = ""; };
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
          # quickshell = quickshell.packages.${system}.default;
          # ncspot = ncspot-flake.packages.${system}.ncspot;
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
        {
          home.username = "stephen";
          home.homeDirectory = "/home/stephen";
          home.stateVersion = "25.05";

          home.packages = with pkgs; [
            aerc
            #aider-chat
            akkuPackages.scheme-langserver
            algol68g
            amp-cli
            anki-bin
            #audacious
            bzflag
            #cheese
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
            fastmail-desktop
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
            #mmixware
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
            # reaper
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
            # zed-editor
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
            darkman = {
              enable = true;
              settings = {
                lat = secrets.location.lat;
                lng = secrets.location.lng;
                usegeoclue = false;
                portal = true;
              };
            };
            easyeffects.enable = true;
          };

          systemd.user.services.cltvpn = {
            Unit = {
              Description = "clt vpn";
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${pkgs.writeShellScript "cltvpn" ''
                ssh-add ${secrets.sshKeyPath}
                ${secrets.vpnScriptPath}
              ''}";
              Restart = "on-failure";
              Environment = [ "USE_AUTOSSH=true" ];
            };
          };
        }
      ];
    };
  };
}
