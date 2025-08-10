return {
    {
        'nvim-telescope/telescope.nvim', 
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
	  "nvim-treesitter/nvim-treesitter",
	  build = ":TSUpdate",
	  opts = {
	    ensure_installed = { "lua", "python", "javascript", "go", "html", "markdown", "markdown_inline"},
	    highlight = { enable = true },
	    indent = { enable = true },
	  },
	  config = function(_, opts)
	    require("nvim-treesitter.configs").setup(opts)
	  end
    },

}
