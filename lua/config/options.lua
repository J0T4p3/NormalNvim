local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.showmatch = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true

-- Behavior
opt.hidden = true
opt.errorbells = false
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.incsearch = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- uses the clipboard register for all operations except yank.
opt.inccommand = "split" 
opt.splitright = true
opt.splitbelow = true
