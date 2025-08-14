return {
    'nvim-telescope/telescope.nvim', 
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
		{ "<leader>ff", ":Telescope find_files<CR>" },
		{ "<leader>fg", ":Telescope live_grep<CR>" },
		{ "<leader>fb", ":Telescope buffers<CR>" },
  },
}
