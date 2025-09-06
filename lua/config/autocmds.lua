-- ~/.config/nvim/lua/config/autocmds.lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Go file settings
local go_group = augroup("GoSettings", { clear = true })
autocmd("FileType", {
  group = go_group,
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- Auto format on save
autocmd("BufWritePre", {
  group = go_group,
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- ~/.config/nvim/lua/config/autocmds.lua (add to existing file)

-- PHP file settings
local php_group = augroup("PhpSettings", { clear = true })

autocmd("FileType", {
  group = php_group,
  pattern = "php",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.commentstring = "// %s"
  end,
})

-- Auto-close PHP tags and add semicolons
autocmd("FileType", {
  group = php_group,
  pattern = "php", 
  callback = function()
    -- Auto-close PHP opening tag
    vim.keymap.set("i", "<?", "<?php<space>", { buffer = true })
    
    -- Quick semicolon at end of line
    vim.keymap.set("i", "<C-;>", "<End>;", { buffer = true })
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
  end,
})
