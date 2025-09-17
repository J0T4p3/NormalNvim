return {
  -- Mason core
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          width = 0.8,
          height = 0.8,
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- PHP Language Server
          "phpactor",         -- Alternative PHP LSP (free)
          -- PHP Code Quality & Analysis
          "phpstan",             -- Static analysis
          "psalm",               -- Static analysis (alternative/additional)
          "php-cs-fixer",        -- Code formatter (PSR standards)
          "phpcbf",             -- PHP Code Beautifier and Fixer
          "phpcs",              -- PHP Code Sniffer
          -- PHP Debugging
          "php-debug-adapter",   -- Debug adapter for DAP
          -- Laravel/Framework specific
          "blade-formatter",     -- Laravel Blade templates
          -- Web Technologies (often used with PHP)
          "html-lsp",           -- HTML language server
          "css-lsp",            -- CSS language server
          "emmet-ls",           -- Emmet support
          "tailwindcss-language-server", -- Tailwind CSS
          -- JavaScript/TypeScript (for full-stack PHP)
          "typescript-language-server",
          "prettier",           -- Code formatter
          "eslint_d",          -- Fast ESLint daemon
          -- JSON/YAML support
          "json-lsp",
          "yaml-language-server",
          -- Other languages you mentioned
          "gopls",              -- Go
          "lua-language-server", -- Lua
          "stylua",            -- Lua formatter
        },
        auto_update = false,
        run_on_start = true,
        start_delay = 3000, -- Wait 3 seconds after startup
        debounce_hours = 5, -- Only check for updates every 5 hours
      })
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
      -- Get capabilities from nvim-cmp
      local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp_ok and cmp_nvim_lsp.default_capabilities() or {}

      -- Wait for mason to be ready
      vim.defer_fn(function()
        mason_lspconfig.setup({
          ensure_installed = {
            "phpactor",      -- PHP
            "html",          -- HTML
            "cssls",         -- CSS
            "emmet_ls",      -- Emmet
            "tailwindcss",   -- Tailwind
            "oxlint",        -- TypeScript
            "jsonls",        -- JSON
            "yamlls",        -- YAML
            "gopls",         -- Go
            "lua_ls",        -- Lua
          },
          automatic_installation = true,
        })

        -- Setup handlers for all servers
        mason_lspconfig.setup_handlers({
          -- Default handler
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
            })
          end,

          -- PHP (Phpactor) - Comprehensive configuration
          ["phpactor"] = function()
            lspconfig.phpactor.setup({
              capabilities = capabilities,
              filetypes = { "php" },
              root_dir = lspconfig.util.root_pattern(
                "composer.json",
                ".git",
                "index.php"
              ),

              settings = {
                phpactor = {
                  language_server_phpstan_enabled = false, -- disable phpstan integration unless needed
                  language_server_psalm_enabled = false,   -- disable psalm integration unless needed
                  index = {
                    enabled = true,
                    path = vim.fn.stdpath("cache") .. "/phpactor/index", -- store index in nvim cache
                    exclude = {
                      "vendor/**/Tests/**",
                      "vendor/**/tests/**",
                      "vendor/**/test/**",
                      "storage/framework/views/*.php",
                      "bootstrap/cache/*.php",
                      "node_modules/**",
                      ".git/**",
                      "tmp/**",
                      "temp/**",
                    },
                  },
                  completion = {
                    limit = 100,
                    resolve = true,
                    insertUse = true, -- auto-insert `use` statements
                  },
                  diagnostics = {
                    enable = true,
                  },
                  workspace = {
                    symbol_search = true,
                  },
                },
              },

              init_options = {
                ["language_server_configuration.auto_configure"] = true,
                ["language_server_phpactor.logging"] = false,
              },
            })
          end,

          -- HTML LSP
          ["html"] = function()
            lspconfig.html.setup({
              capabilities = capabilities,
              filetypes = { "html", "php", "blade" },
              settings = {
                html = {
                  format = {
                    enable = true,
                    indentInnerHtml = true,
                      wrapLineLength = 80,
                      wrapAttributes = "force-aligned", -- options: "auto", "force", "force-aligned", "force-expand-multiline"
                  },
                },
              },
            })
          end,

          -- CSS LSP  
          ["cssls"] = function()
            lspconfig.cssls.setup({
              capabilities = capabilities,
              settings = {
                css = {
                  validate = true,
                  lint = {
                    unknownAtRules = "ignore",
                  },
                },
              },
            })
          end,

          -- Emmet for HTML/CSS in PHP files
          ["emmet_ls"] = function()
            lspconfig.emmet_ls.setup({
              capabilities = capabilities,
              filetypes = { 
                "html", "css", "scss", "javascript", "javascriptreact", 
                "typescript", "typescriptreact", "php", "blade" 
              },
              init_options = {
                html = {
                  options = {
                    ["bem.enabled"] = true,
                  },
                },
              },
            })
          end,

          -- Tailwind CSS
          ["tailwindcss"] = function()
            lspconfig.tailwindcss.setup({
              capabilities = capabilities,
              filetypes = { "html", "css", "php", "blade", "vue", "javascript", "typescript" },
              settings = {
                tailwindCSS = {
                  includeLanguages = {
                    php = "html",
                    blade = "html",
                  },
                  experimental = {
                    classRegex = {
                      "class[:]\\s*['\"]([^'\"]*)['\"]",
                      "class[:]\\s*['\"]([^'\"]*)['\"]",
                    },
                  },
                },
              },
            })
          end,

          -- Go LSP (from your existing config)
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
            })
          end,

          -- Lua LSP (from your existing config)
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = {
                    version = "LuaJIT",
                  },
                  diagnostics = {
                    globals = { "vim" },
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
                  on_attach = function(client, bufnr)
                    -- enable format on save
                    if client.server_capabilities.documentFormattingProvider then
                      vim.api.nvim_create_autocmd("BufWritePre", {
                        group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
                        buffer = bufnr,
                        callback = function()
                          vim.lsp.buf.format({ bufnr = bufnr })
                        end,
                      })
                    end
                  end,
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
            vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
            
            -- Information
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
            
            -- Actions
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>f", function()
              vim.lsp.buf.format({ async = true })
            end, opts)
            -- Diagnostics
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
            
            -- Workspace
            vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set("n", "<leader>wl", function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
          end,
        })

        -- Diagnostic configuration
        vim.diagnostic.config({
          virtual_text = {
            prefix = "●",
            spacing = 2,
            severity = vim.diagnostic.severity.ERROR, -- Only show errors inline
          },
          signs = {
            severity = { min = vim.diagnostic.severity.HINT },
          },
          underline = {
            severity = { min = vim.diagnostic.severity.WARN },
          },
          update_in_insert = false,
          severity_sort = true,
          float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
            format = function(diagnostic)
              return string.format("%s (%s)", diagnostic.message, diagnostic.source)
            end,
          },
        })

        -- Customize diagnostic signs
        local signs = { Error = " ", Warn = " ", Hint = "󰌶 ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

      end, 200) -- 200ms delay to ensure mason is ready
    end,
  },
{
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            extra_args = { "--print-width", "80", "--html-whitespace-sensitivity", "ignore" },
          }),
        },
      })
    end,
  },
  -- LSP Configuration (standalone for manual servers)
  {
    "neovim/nvim-lspconfig",
    lazy = true, -- Only loaded by mason-lspconfig
  },
}
