local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")

-- PHP specific configuration
require("config.php-config").setup()

-- PHP custom ColorScheme
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Custom PHP variable highlighting
    vim.api.nvim_set_hl(0, "phpVariable", { fg = "#e06c75", italic = true })
    -- Custom PHP function highlighting  
    vim.api.nvim_set_hl(0, "phpFunction", { fg = "#61afef", bold = true })
    -- Custom PHP class highlighting
    vim.api.nvim_set_hl(0, "phpClass", { fg = "#e5c07b", bold = true })
  end,
})

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  checker = { enabled = true },
})
