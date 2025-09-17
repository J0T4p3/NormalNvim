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

}
