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
