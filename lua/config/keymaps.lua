-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Easier ident in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv") 
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

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
