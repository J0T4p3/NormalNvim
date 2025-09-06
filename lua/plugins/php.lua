-- ~/.config/nvim/lua/plugins/php.lua
return {
  -- PHP-specific enhancements
  {
    "gbprod/php-enhanced-treesitter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = "php",
    config = true,
  },

  -- Laravel Blade syntax highlighting
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
      "nvimtools/none-ls.nvim",
      "nvim-neotest/nvim-nio"
    },
    cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    keys = {
      { "<leader>la", ":Laravel artisan<cr>", desc = "Laravel Artisan" },
      { "<leader>lr", ":Laravel routes<cr>", desc = "Laravel Routes" },
      { "<leader>lm", ":Laravel related<cr>", desc = "Laravel Related" },
    },
    event = { "VeryLazy" },
    config = true,
  },

  -- Composer integration
  {
    "noahfrederick/vim-composer",
    ft = "php",
    cmd = { "Composer" },
  },

  -- PHP Refactoring tools
  {
    "adoy/vim-php-refactoring-toolbox", 
    ft = "php",
    keys = {
      { "<leader>rlv", ":call PhpRenameLocalVariable()<CR>", desc = "Rename local variable" },
      { "<leader>rcv", ":call PhpRenameClassVariable()<CR>", desc = "Rename class variable" },
      { "<leader>rm", ":call PhpRenameMethod()<CR>", desc = "Rename method" },
      { "<leader>eu", ":call PhpExtractUse()<CR>", desc = "Extract use statement" },
      { "<leader>ec", ":call PhpExtractConst()<CR>", desc = "Extract constant" },
      { "<leader>ep", ":call PhpExtractClassProperty()<CR>", desc = "Extract class property" },
      { "<leader>em", ":call PhpExtractMethod()<CR>", desc = "Extract method", mode = "v" },
      { "<leader>np", ":call PhpCreateProperty()<CR>", desc = "Create property" },
      { "<leader>du", ":call PhpDetectUnusedUseStatements()<CR>", desc = "Detect unused use" },
      { "<leader>sg", ":call PhpCreateSettersAndGetters()<CR>", desc = "Create setters/getters" },
    },
  },

  -- Better PHP indentation
  {
    "2072/PHP-Indenting-for-VIm",
    ft = "php",
  },
}
