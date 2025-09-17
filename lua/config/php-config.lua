local M = {}

-- PHP-specific autocmds
function M.setup_autocmds()
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd

  -- PHP file settings
  local php_group = augroup("PhpSettings", { clear = true })

  autocmd("FileType", {
    group = php_group,
    pattern = "php",
    callback = function()
      -- Indentation settings
      vim.opt_local.tabstop = 4
      vim.opt_local.shiftwidth = 4
      vim.opt_local.expandtab = true
      vim.opt_local.softtabstop = 4
      
      -- Comment settings
      vim.opt_local.commentstring = "// %s"
      
      -- PHP-specific options
      vim.opt_local.iskeyword:append("$") -- Include $ in word boundaries
      vim.opt_local.suffixesadd:prepend(".php") -- For gf command
      
      -- Folding
      vim.opt_local.foldmethod = "indent"
      vim.opt_local.foldlevel = 20
    end,
  })

  -- Laravel Blade file settings
  autocmd({ "BufNewFile", "BufRead" }, {
    group = php_group,
    pattern = "*.blade.php",
    callback = function()
      vim.bo.filetype = "blade"
      vim.opt_local.tabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.expandtab = true
      vim.opt_local.commentstring = "{{-- %s --}}"
    end,
  })

  -- Auto-insert PHP opening tag for new files
  autocmd("BufNewFile", {
    group = php_group,
    pattern = "*.php",
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      if #lines == 1 and lines[1] == "" then
        vim.api.nvim_buf_set_lines(0, 0, 1, false, {"<?php", "", ""})
        vim.api.nvim_win_set_cursor(0, {3, 0})
      end
    end,
  })

  -- Auto-format PHP files on save (if LSP supports it)
  autocmd("BufWritePre", {
    group = php_group,
    pattern = "*.php",
    callback = function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      for _, client in pairs(clients) do
        if client.name == "intelephense" and client.supports_method("textDocument/formatting") then
          vim.lsp.buf.format({
            async = false,
            timeout_ms = 5000,
            filter = function(c)
              return c.name == "intelephense"
            end,
          })
          break
        end
      end
    end,
  })

  -- Highlight PHP variables
  autocmd("FileType", {
    group = php_group,
    pattern = "php",
    callback = function()
      vim.cmd([[
        syntax match phpVariable "\$\w\+" containedin=ALL
        highlight link phpVariable Identifier
      ]])
    end,
  })
end

-- PHP-specific keymaps
function M.setup_keymaps()
  local keymap = vim.keymap.set
  
  -- PHP-specific keymaps (only active in PHP files)
  local php_group = vim.api.nvim_create_augroup("PhpKeymaps", { clear = true })
  
  vim.api.nvim_create_autocmd("FileType", {
    group = php_group,
    pattern = "php",
    callback = function()
      local opts = { buffer = true, silent = true }
      
      -- === PHP Execution ===
      keymap("n", "<leader>pr", ":!php %<CR>", { buffer = true, desc = "Run PHP file" })
      keymap("n", "<leader>pc", ":!php -l %<CR>", { buffer = true, desc = "Check PHP syntax" })
      keymap("n", "<leader>ps", ":!php -S localhost:8000<CR>", { buffer = true, desc = "Start PHP server" })
      
      -- === Composer Commands ===
      keymap("n", "<leader>ci", ":!composer install<CR>", { buffer = true, desc = "Composer install" })
      keymap("n", "<leader>cu", ":!composer update<CR>", { buffer = true, desc = "Composer update" })
      keymap("n", "<leader>cr", ":!composer require ", { buffer = true, desc = "Composer require" })
      keymap("n", "<leader>cd", ":!composer dump-autoload<CR>", { buffer = true, desc = "Composer dump-autoload" })
      keymap("n", "<leader>cs", ":!composer show<CR>", { buffer = true, desc = "Composer show packages" })
      
      -- === Laravel Artisan Commands ===
      keymap("n", "<leader>am", ":!php artisan migrate<CR>", { buffer = true, desc = "Artisan migrate" })
      keymap("n", "<leader>as", ":!php artisan serve<CR>", { buffer = true, desc = "Artisan serve" })
      keymap("n", "<leader>at", ":!php artisan tinker<CR>", { buffer = true, desc = "Artisan tinker" })
      keymap("n", "<leader>ar", ":!php artisan route:list<CR>", { buffer = true, desc = "Artisan routes" })
      keymap("n", "<leader>ac", ":!php artisan config:cache<CR>", { buffer = true, desc = "Artisan config cache" })
      keymap("n", "<leader>aq", ":!php artisan queue:work<CR>", { buffer = true, desc = "Artisan queue work" })
      
      -- === PHP Code Generation ===
      keymap("i", "<?", "<?php ", opts)
      
      -- === PHP Class/Function Navigation ===
      keymap("n", "<leader>pf", function()
        vim.cmd("normal! /function \\|class \\|interface \\|trait<CR>")
      end, { buffer = true, desc = "Find next function/class" })
      
      keymap("n", "<leader>pF", function()
        vim.cmd("normal! ?function \\|class \\|interface \\|trait<CR>")
      end, { buffer = true, desc = "Find previous function/class" })
      
      -- === PHP Documentation ===
      keymap("n", "<leader>pd", function()
        local word = vim.fn.expand("<cword>")
        vim.cmd("!open https://www.php.net/manual/en/function." .. word .. ".php")
      end, { buffer = true, desc = "PHP documentation" })
      
      -- === PHP Testing ===
      keymap("n", "<leader>pt", ":!./vendor/bin/phpunit<CR>", { buffer = true, desc = "Run PHPUnit tests" })
      keymap("n", "<leader>pT", ":!./vendor/bin/phpunit %<CR>", { buffer = true, desc = "Run current file tests" })
      keymap("n", "<leader>pe", ":!./vendor/bin/pest<CR>", { buffer = true, desc = "Run Pest tests" })
      keymap("n", "<leader>pE", ":!./vendor/bin/pest %<CR>", { buffer = true, desc = "Run current file with Pest" })
      
      -- === PHP Debugging ===
      keymap("n", "<leader>pdb", "ivar_dump();<Left><Left>", { buffer = true, desc = "Insert var_dump" })
      keymap("n", "<leader>pdd", "idd();<Left><Left>", { buffer = true, desc = "Insert dd()" })
      
      -- === PHP Refactoring (works with LSP) ===
      keymap("n", "<leader>piu", function()
        vim.lsp.buf.code_action({
          filter = function(action)
            return action.title:find("Import") or action.title:find("Add use")
          end,
          apply = true,
        })
      end, { buffer = true, desc = "Import/Add use statement" })
      
      keymap("n", "<leader>psu", function()
        vim.lsp.buf.code_action({
          filter = function(action)
            return action.title:find("Sort")
          end,
          apply = true,
        })
      end, { buffer = true, desc = "Sort use statements" })

      -- === Quick semicolon ===
      keymap("i", "<C-;>", "<End>;", opts)
      keymap("n", "<leader>;", "A;<Esc>", { buffer = true, desc = "Add semicolon at end of line" })
      
      -- === PHP Documentation blocks ===
      keymap("i", "/**", "/**<CR> * <CR> */<Up><End>", opts)
      
      -- === Laravel Blade specific (when in blade files) ===
      if vim.bo.filetype == "blade" then
        keymap("i", "{{", "{{ }}<Left><Left><Left>", opts)
        keymap("i", "{!!", "{!! !!}<Left><Left><Left><Left>", opts)
        keymap("i", "@if", "@if ()<CR>@endif<Up><End><Left>", opts)
        keymap("i", "@for", "@foreach ( as )<CR>@endforeach<Up><End><Left><Left><Left><Left><Left><Left>", opts)
      end
    end,
  })
  
  -- Global PHP-related keymaps (always available)
  keymap("n", "<leader>php", ":e ~/.config/nvim/lua/plugins/php-mason.lua<CR>", { desc = "Edit PHP config" })
end

-- Setup function to be called from your config
function M.setup()
  M.setup_autocmds()
  M.setup_keymaps()
end

return M
