{ pkgs, ... }:

let
  debugAdapterPaths = ''
    vim.g.nixvim_js_debug_adapter = "${pkgs.vscode-js-debug}/bin/js-debug"
    vim.g.nixvim_php_debug_adapter = "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js"
  '';
  disableSyntaxAfterFtplugin = ''
    pcall(vim.treesitter.stop)
    vim.bo.syntax = "OFF"
  '';
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
    bash
    # zsh DO NOT USE because big memory leak
    javascript
    latex
    lua
    markdown
    markdown_inline
    nix
    php
    r
    rust
    scheme
    tsx
    typescript
    vim
  ]);
in
{
  nixpkgs.config.allowUnfree = true;

  programs.nixvim = {
    enable = true;
    nixpkgs.source = pkgs.path;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Core
    globals = {
      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
      mapleader = " ";
      maplocalleader = ",";
    };

    opts = {
      autowriteall = false;
      clipboard = "unnamedplus";
      conceallevel = 2;
      cursorline = true;
      cursorlineopt = "line";
      expandtab = true;
      foldlevel = 99;
      foldlevelstart = 99;
      foldmethod = "expr";
      guicursor = [
        "n-v-c:block"
        "i-ci:block-blinkwait700-blinkon400-blinkoff250"
        "r-cr:block-blinkwait700-blinkon400-blinkoff250"
      ];
      hlsearch = true;
      ignorecase = true;
      linebreak = true;
      linespace = 2;
      modeline = false;
      modelines = 0;
      number = true;
      pumborder = "rounded";
      relativenumber = true;
      scrolloff = 5;
      shiftwidth = 2;
      sidescrolloff = 5;
      signcolumn = "yes";
      swapfile = true;
      syntax = "OFF";
      tabstop = 2;
      termguicolors = false;
      textwidth = 0;
      title = true;
      undofile = true;
      updatetime = 300;
      winborder = "rounded";
      wrap = false;
      wrapscan = true;
    };

    highlight.ExtraWhitespace = {
      bg = "red";
      ctermbg = "red";
    };

    highlightOverride = {
      DiffAdd = {
        fg = "#a6e3a1";
        bg = "NONE";
      };
      DiffDelete = {
        fg = "#f38ba8";
        bg = "NONE";
      };
      DiffChange.bg = "NONE";
      DiffText.bg = "#45475a";
    };

    userCommands = {
      RemoveTrailingWhitespace.command = "%s/\\s\\+$//e";
      BlameToggle.command = "Gitsigns blame";
      DiffUnsaved.command = "w !diff -u % -";
    };

    keymaps = [
      {
        key = "<F1>";
        action = "<Nop>";
        mode = [ "n" "i" "v" "x" "s" "o" "c" ];
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-s>";
        action = "<cmd>w<CR>";
        options.desc = "Save file";
      }
      {
        mode = "i";
        key = "<C-s>";
        action = "<Esc><cmd>w<CR>a";
        options.desc = "Save file";
      }
      {
        mode = "n";
        key = "<A-Down>";
        action = "<cmd>m .+1<CR>==";
        options.desc = "Move line down";
      }
      {
        mode = "n";
        key = "<A-Up>";
        action = "<cmd>m .-2<CR>==";
        options.desc = "Move line up";
      }
      {
        mode = "i";
        key = "<A-Down>";
        action = "<Esc><cmd>m .+1<CR>==gi";
        options.desc = "Move line down";
      }
      {
        mode = "i";
        key = "<A-Up>";
        action = "<Esc><cmd>m .-2<CR>==gi";
        options.desc = "Move line up";
      }
      {
        mode = "v";
        key = "<A-Down>";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move selection down";
      }
      {
        mode = "v";
        key = "<A-Up>";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move selection up";
      }
      # flash, TODO
      {
        mode = "o";
        key = "r";
        action = "<cmd>lua require('flash').remote()<CR>";
        options = {
          desc = "Flash remote";
          silent = true;
        };
      }
    ];

    # Packages
    extraPackages = with pkgs; [
      akkuPackages.scheme-langserver
      ast-grep
      fd
      gh
      git
      lazygit
      lua-language-server
      luaPackages.luacheck
      nixd
      shfmt
      vtsls
      vscode-langservers-extracted
      nodejs_24
      phpactor
      rPackages.languageserver
      ripgrep
      rust-analyzer
      tree-sitter
    ];

    extraPlugins = with pkgs.vimPlugins; [
      aerial-nvim
      # barbar-nvim
      bullets-vim
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      fidget-nvim
      flash-nvim
      gitlinker-nvim
      gitsigns-nvim
      grug-far-nvim
      lazygit-nvim
      luasnip
      mini-surround
      nvim-cmp
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-lint
      nvim-lspconfig
      nvim-nio
      nvim-treesitter-context
      nvim-treesitter-textobjects
      nvim-web-devicons
      obsidian-nvim
      plenary-nvim
      rustaceanvim
      tabout-nvim
      telescope-file-browser-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      telescope-sg
      telescope-frecency-nvim
      treesitter
      # treesj
      trouble-nvim
      vim-tmux-navigator
      yazi-nvim
    ];

    # Syntax highlighting
    extraFiles = {
      "after/ftplugin/help.lua".text = disableSyntaxAfterFtplugin;
      "after/ftplugin/lua.lua".text = disableSyntaxAfterFtplugin;
      "after/ftplugin/markdown.lua".text = disableSyntaxAfterFtplugin;
      "after/ftplugin/query.lua".text = disableSyntaxAfterFtplugin;
      "after/indent/lua.lua".text = ''
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      '';
    };

    # LSP
    lsp.inlayHints.enable = false;

    # Lua
    extraConfigLua = builtins.concatStringsSep "\n" [
      debugAdapterPaths
      (builtins.readFile ./nixvim.lua)
    ];
  };
}
