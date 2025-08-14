-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- Mason core
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        -- Go tools
        "gopls",           -- Go LSP
        "gofumpt",         -- Go formatter
        "goimports",       -- Go imports
        "golangci-lint",   -- Go linter

        -- Lua tools
        "lua-language-server",  -- Lua LSP
        "stylua",              -- Lua formatter
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Mason-LSP integration
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Setup mason-lspconfig first
      mason_lspconfig.setup({
        ensure_installed = { "gopls", "lua_ls" },
        automatic_installation = true,
      })

      -- Setup handlers for all servers installed via Mason
      mason_lspconfig.setup_handlers({
        -- Default handler for all servers
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,

        -- Custom handler for gopls
        ["gopls"] = function()
          lspconfig.gopls.setup({
            capabilities = capabilities,
            settings = {
              gopls = {
                analyses = {
                  unusedparams = true,
                  shadow = true,
                },
                staticcheck = true,
                gofumpt = true,
                usePlaceholders = true,
                completeUnimported = true,
                matcher = "fuzzy",
                experimentalWorkspaceModule = true,
              },
            },
            on_attach = function(client, bufnr)
              -- Disable semantic highlighting (optional)
              -- client.server_capabilities.semanticTokensProvider = nil
              
              -- Auto-organize imports on save
              if client.supports_method("textDocument/codeAction") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = vim.api.nvim_create_augroup("GoImports", { clear = true }),
                  buffer = bufnr,
                  callback = function()
                    local params = vim.lsp.util.make_range_params()
                    params.context = { only = { "source.organizeImports" } }
                    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
                    for _, res in pairs(result or {}) do
                      for _, action in pairs(res.result or {}) do
                        if action.edit then
                          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                        else
                          vim.lsp.buf.execute_command(action.command)
                        end
                      end
                    end
                  end,
                })
              end
            end,
          })
        end,

        -- Custom handler for Lua LSP
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" }, -- Recognize 'vim' global
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
                format = {
                  enable = true,
                  defaultConfig = {
                    indent_style = "space",
                    indent_size = "2",
                  },
                },
              },
            },
          })
        end,
      })

      -- Global LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          
          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
          
          -- Information
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          
          -- Actions
          vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, opts)
          vim.keymap.set("v", "<leader>ga", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>gf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
          
          -- Diagnostics
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
        end,
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 2,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end,
  },

  -- Autocompletion
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
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Add source name
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },
}
