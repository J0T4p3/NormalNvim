return {
    -- LSP
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
          local lspconfig = require("lspconfig")
          local capabilities = require("cmp_nvim_lsp").default_capabilities()

          -- Go LSP
          lspconfig.gopls.setup({
            capabilities = capabilities,
            settings = {
              gopls = {
                analyses = {
                  unusedparams = true,
                },
                staticcheck = true,
                gofumpt = true,
              },
            },
          })

          -- Key mappings
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
              local opts = { buffer = ev.buf }
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
              vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
              vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
              vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
              vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            end,
          })
        end,

    -- Autocomplete
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                    }, {
                        { name = "buffer" },
                        { name = "path" },
                    }),
				})
			end,
		},
	},
}
