{ pkgs, ... }:

let
  debugAdapterPaths = ''
    vim.g.nixvim_js_debug_adapter = "${pkgs.vscode-js-debug}/bin/js-debug"
    vim.g.nixvim_php_debug_adapter = "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js"
  '';
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
    bash
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
    typescript
    vim
  ]);
in
{
  imports = [
    ./nixvim/01-core.nix
    ./nixvim/02-lsp.nix
  ];

  nixpkgs.config.allowUnfree = true;

  programs.nixvim = {
    enable = true;
    nixpkgs.source = pkgs.path;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      akkuPackages.scheme-langserver
      fd
      gh
      git
      lazygit
      lua-language-server
      nixd
      typescript-language-server
      vscode-langservers-extracted
      nodejs_24
      phpactor
      rPackages.languageserver
      ripgrep
      tree-sitter
    ];

    extraPlugins = with pkgs.vimPlugins; [
      aerial-nvim
      barbar-nvim
      bullets-vim
      cmp-buffer
      cmp-conjure
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      conjure
      gitlinker-nvim
      gitsigns-nvim
      grug-far-nvim
      lazydev-nvim
      lazygit-nvim
      luasnip
      mini-surround
      nvim-cmp
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-lspconfig
      nvim-nio
      nvim-treesitter-context
      nvim-treesitter-textobjects
      nvim-web-devicons
      obsidian-nvim
      plenary-nvim
      rustaceanvim
      telescope-file-browser-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      treesitter
      trouble-nvim
      vim-tmux-navigator
    ];

    extraConfigLua = builtins.concatStringsSep "\n" [
      debugAdapterPaths
      (builtins.readFile ./nvim-lua/02-lsp.lua)
      (builtins.readFile ./nvim-lua/03-treesitter.lua)
      (builtins.readFile ./nvim-lua/04-telescope.lua)
      (builtins.readFile ./nvim-lua/05-completion.lua)
      (builtins.readFile ./nvim-lua/06-outline.lua)
      (builtins.readFile ./nvim-lua/07-notes.lua)
      (builtins.readFile ./nvim-lua/08-debugging.lua)
      (builtins.readFile ./nvim-lua/09-git.lua)
      (builtins.readFile ./nvim-lua/10-ui.lua)
      (builtins.readFile ./nvim-lua/11-rust.lua)
      (builtins.readFile ./nvim-lua/12-tmux.lua)
    ];
  };
}
