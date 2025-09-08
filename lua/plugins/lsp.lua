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

  -- Tool installer for PHP ecosystem
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- PHP Language Server
          "intelephense",        -- Premium PHP LSP (best option)
          -- "phpactor",         -- Alternative PHP LSP (free)
          
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
      
      -- Enhanced capabilities for PHP development
      capabilities.textDocument.completion.completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        deprecatedSupport = true,
        commitCharactersSupport = true,
        tagSupport = { valueSet = { 1 } },
        resolveSupport = {
          properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
          },
        },
      }

      -- Wait for mason to be ready
      vim.defer_fn(function()
        mason_lspconfig.setup({
          ensure_installed = {
            "intelephense",  -- PHP
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

          -- PHP (Intelephense) - Comprehensive configuration
          ["intelephense"] = function()
            lspconfig.intelephense.setup({
              capabilities = capabilities,
              settings = {
                intelephense = {
                  -- File associations
                  files = {
                    maxSize = 5000000, -- 5MB max file size
                    associations = { "*.php", "*.phtml", "*.php3", "*.php4", "*.php5", "*.phps" },
                    exclude = {
                      "**/node_modules/**",
                      "**/vendor/**/Tests/**",
                      "**/vendor/**/tests/**",
                      "**/vendor/**/test/**",
                      "**/storage/framework/views/*.php",
                      "**/bootstrap/cache/*.php",
                      "**/.git/**",
                      "**/tmp/**",
                      "**/temp/**",
                    },
                  },
                  
                  -- Stubs for better completion (common PHP extensions)
                  stubs = {
                    "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core", "ctype", "curl", "date",
                    "dba", "dom", "enchant", "exif", "FFI", "fileinfo", "filter", "fpm", "ftp", "gd",
                    "gettext", "gmp", "hash", "iconv", "imap", "intl", "json", "ldap", "libxml",
                    "mbstring", "meta", "mysqli", "oci8", "odbc", "openssl", "pcntl", "pcre",
                    "PDO", "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar",
                    "posix", "pspell", "readline", "Reflection", "session", "shmop", "SimpleXML",
                    "snmp", "soap", "sockets", "sodium", "SPL", "sqlite3", "standard", "superglobals",
                    "sysvmsg", "sysvsem", "sysvshm", "tidy", "tokenizer", "xml", "xmlreader",
                    "xmlrpc", "xmlwriter", "xsl", "Zend OPcache", "zip", "zlib",
                    -- Framework stubs
                    "wordpress", "laravel", "symfony", "phpunit", "pest"
                  },
                  
                  -- Environment configuration
                  environment = {
                    includePaths = { "vendor/", "app/", "src/", "lib/" },
                    documentRoot = "",
                    shortOpenTag = false,
                  },
                  
                  -- Completion settings
                  completion = {
                    insertUseDeclaration = true,
                    fullyQualifyGlobalConstantsAndFunctions = false,
                    triggerParameterHints = true,
                    maxItems = 100,
                  },
                  
                  -- Format settings
                  format = {
                    enable = true,
                    braces = "psr12", -- PSR-12 brace style
                  },
                  
                  -- Diagnostic settings
                  diagnostics = {
                    enable = true,
                    run = "onType",
                    embeddedLanguages = true,
                    undefinedSymbols = true,
                    undefinedFunctions = true,
                    undefinedConstants = true,
                    undefinedClassConstants = true,
                    undefinedMethods = true,
                    undefinedProperties = true,
                    undefinedTypes = true,
                    unusedSymbols = true,
                  },
                  
                  -- PhpDoc settings
                  phpDoc = {
                    returnVoid = false,
                    textFormat = "snippet",
                  },
                  
                  -- Indexing settings
                  indexing = {
                    maxFileSize = 5000000,
                  },
                  
                  -- Trace settings (for debugging)
                  trace = {
                    server = "off", -- Set to "verbose" for debugging
                  },
                },
              },
              
              -- Custom on_attach for PHP-specific features
              on_attach = function(client, bufnr)
                -- Enable auto-formatting on save
                if client.supports_method("textDocument/formatting") then
                  vim.api.nvim_create_autocmd("BufWritePre", {
                    group = vim.api.nvim_create_augroup("PhpLspFormat", { clear = true }),
                    buffer = bufnr,
                    callback = function()
                      vim.lsp.buf.format({
                        async = false,
                        timeout_ms = 2000,
                      })
                    end,
                  })
                end

                -- PHP-specific keymaps
                local opts = { buffer = bufnr, silent = true }
                vim.keymap.set("n", "<leader>pi", function()
                  vim.lsp.buf.code_action({
                    filter = function(action)
                      return action.title:find("Import") or action.title:find("use")
                    end,
                    apply = true,
                  })
                end, { buffer = bufnr, desc = "PHP: Import class" })
                
                vim.keymap.set("n", "<leader>ps", function()
                  vim.lsp.buf.code_action({
                    filter = function(action)
                      return action.title:find("Sort")
                    end,
                    apply = true,
                  })
                end, { buffer = bufnr, desc = "PHP: Sort imports" })
              end,

              -- Custom initialization options
              init_options = {
                storagePath = vim.fn.stdpath("cache") .. "/intelephense",
                globalStoragePath = vim.fn.stdpath("cache") .. "/intelephense",
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
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
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

  -- LSP Configuration (standalone for manual servers)
  {
    "neovim/nvim-lspconfig",
    lazy = true, -- Only loaded by mason-lspconfig
  },
}
