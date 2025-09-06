-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Easier ident in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv") 
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- Better window navigation (only when not in tmux)
if not vim.env.TMUX then
  keymap("n", "<C-h>", "<C-w>h")
  keymap("n", "<C-j>", "<C-w>j")
  keymap("n", "<C-k>", "<C-w>k")
  keymap("n", "<C-l>", "<C-w>l")
end

-- Window resizing (when not using tmux.nvim Alt keys)
keymap("n", "<C-Up>", ":resize -2<CR>")
keymap("n", "<C-Down>", ":resize +2<CR>")
keymap("n", "<C-Left>", ":vertical resize -2<CR>")
keymap("n", "<C-Right>", ":vertical resize +2<CR>")

-- Tmux-specific keymaps
if vim.env.TMUX then
  -- Quick pane creation
  keymap("n", "<leader>tv", ":!tmux split-window -h<CR><CR>", { desc = "Tmux vertical split" })
  keymap("n", "<leader>th", ":!tmux split-window -v<CR><CR>", { desc = "Tmux horizontal split" })
  keymap("n", "<leader>tt", ":!tmux new-window<CR><CR>", { desc = "Tmux new window" })

  -- Send current line/selection to tmux pane
  keymap("n", "<leader>sl", ":.SlimeSend<CR>", { desc = "Send line to tmux" })
  keymap("v", "<leader>ss", ":SlimeSend<CR>", { desc = "Send selection to tmux" })
end

-- Go-specific mappings
keymap("n", "<leader>gr", ":GoRun<CR>", { desc="Run Go code"})
keymap("n", "<leader>gt", ":GoTest<CR>", { desc="Test Go code" })
keymap("n", "<leader>gf", ":GoFmt<CR>", { desc="Format Go code" })
keymap("n", "<leader>gi", ":GoImport<CR>", { desc="Import Go dependencies" })

-- LSP-related (additional to autocmd)
keymap("n", "<leader>d", vim.diagnostic.open_float, {desc="Open floating diagnostic"})
keymap("n", "[d", vim.diagnostic.goto_prev, {desc="Go to next diagnostic"})
keymap("n", "]d", vim.diagnostic.goto_next, {desc="Go to previous diagnostic"})

-- File explorer
keymap("n", "<leader>e", ":Explore<CR>", {desc="Open file explorer"})

-- PHP-specific mappings
local php_group = vim.api.nvim_create_augroup("PhpKeymaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = php_group,
  pattern = "php",
  callback = function()
    local opts = { buffer = true, silent = true }
    
    -- PHP execution
    keymap("n", "<leader>pr", ":!php %<CR>", { buffer = true, desc = "Run PHP file" })
    keymap("n", "<leader>pc", ":!php -l %<CR>", { buffer = true, desc = "Check PHP syntax" })
    
    -- Composer commands
    keymap("n", "<leader>ci", ":!composer install<CR>", opts)
    keymap("n", "<leader>cu", ":!composer update<CR>", opts)
    keymap("n", "<leader>cd", ":!composer dump-autoload<CR>", opts)
    
    -- Laravel Artisan (when using Laravel)
    keymap("n", "<leader>am", ":!php artisan migrate<CR>", opts)
    keymap("n", "<leader>as", ":!php artisan serve<CR>", opts)
    keymap("n", "<leader>at", ":!php artisan tinker<CR>", opts)
    
    -- Quick PHP snippets
    keymap("i", "vd", "var_dump();<Left><Left>", opts)
    keymap("i", "dd", "dd();<Left><Left>", opts) -- Laravel helper
    keymap("i", "eco", "echo '';<Left><Left>", opts)
  end,
})
