{ lib, ... }:

{
  programs.nixvim = {
    globals = {
      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
      mapleader = " ";
      maplocalleader = ",";
    };

    opts = {
      number = false;
      relativenumber = false;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      clipboard = "unnamedplus";
      ignorecase = true;
      linespace = 2;
      conceallevel = 2;
      autowriteall = false;
      cursorline = true;
      cursorlineopt = "line";
      signcolumn = "yes";
      termguicolors = false;
      scrolloff = 5;
      guicursor = [
        "n-v-c:block"
        "i-ci:block-blinkwait700-blinkon400-blinkoff250"
        "r-cr:block-blinkwait700-blinkon400-blinkoff250"
      ];
      wrap = false;
      winborder = "rounded";
      pumborder = "rounded";
      linebreak = true;
      textwidth = 0;
      sidescrolloff = 5;
      foldmethod = "expr";
      foldlevel = 99;
      foldlevelstart = 1;
      updatetime = 5000;
      undofile = true;
      swapfile = true;
      title = true;
      wrapscan = true;
      hlsearch = true;
      modeline = false;
      modelines = 0;
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
      {
        mode = "x";
        key = "<leader>s";
        action = ":s/\\%V";
      }
    ];

    extraConfigLua = lib.mkBefore (builtins.readFile ./01-core.lua);
  };
}
