return {
  -- Better PHP syntax and indentation
  {
    "StanAngeloff/php.vim",
    ft = "php",
    init = function()
      -- Enable PHP syntax folding
      vim.g.php_folding = 1
      -- Enable PHP HTML syntax highlighting
      vim.g.php_htmlInStrings = 1
      -- Enable PHP SQL syntax highlighting
      vim.g.php_sql_query = 1
    end,
  },

  -- Laravel Blade templates
  {
    "jwalton512/vim-blade",
    ft = "blade",
  },

  -- Composer integration (lightweight)
  {
    "noahfrederick/vim-composer",
    ft = "php",
    cmd = { "Composer" },
  },

  -- PHP namespace management
  {
    "arnaud-lb/vim-php-namespace",
    ft = "php",
    keys = {
      { "<leader>u", ":call PhpInsertUse()<CR>", ft = "php", desc = "Insert use statement" },
      { "<leader>e", ":call PhpExpandClass()<CR>", ft = "php", desc = "Expand class name" },
      { "<leader>s", ":call PhpSortUse()<CR>", ft = "php", desc = "Sort use statements" },
    },
    config = function()
      -- Enable automatic namespace insertion
      vim.g.php_namespace_sort_after_insert = 1
    end,
  },
  -- Laravel integration
    --[[
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
    },
    cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    keys = {
      { "<leader>la", ":Laravel artisan<cr>", desc = "Laravel Artisan" },
      { "<leader>lr", ":Laravel routes<cr>", desc = "Laravel Routes" },
      { "<leader>lm", ":Laravel related<cr>", desc = "Laravel Related" },
    },
    ft = { "php", "blade" },
    config = function()
      require("laravel").setup({
        lsp_server = "intelephense",
        features = {
          null_ls = {
            enable = false, -- We're not using null-ls
          },
        },
      })
    end,
  },
  --]]
}
