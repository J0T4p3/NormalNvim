-- Dev
-- Plugins you actively use for coding.

--    Sections:
--       ## SNIPPETS
--       -> luasnip                        [snippet engine]
--       -> friendly-snippets              [snippet templates]

--       ## GIT
--       -> gitsigns.nvim                  [git hunks]
--       -> fugitive.vim                   [git commands]

--       ## ANALYZER
--       -> aerial.nvim                    [symbols tree]
--       -> litee-calltree.nvim            [calltree]

--       ## CODE DOCUMENTATION
--       -> dooku.nvim                     [html doc generator]
--       -> markdown-preview.nvim          [markdown previewer]
--       -> markmap.nvim                   [markdown mindmap]

--       ## ARTIFICIAL INTELLIGENCE
--       -> neural                         [chatgpt code generator]
--       -> copilot                        [github code suggestions]
--       -> guess-indent                   [guess-indent]

--       ## COMPILER
--       -> compiler.nvim                  [compiler]
--       -> overseer.nvim                  [task runner]

--       ## DEBUGGER
--       -> nvim-dap                       [debugger]

--       ## TESTING
--       -> neotest.nvim                   [unit testing]
--       -> nvim-coverage                  [code coverage]

--       ## LANGUAGE IMPROVEMENTS
--       -> guttentags_plus                [auto generate C/C++ tags]

local is_windows = vim.fn.has('win32') == 1 -- true if on windows

return {
  --  SNIPPETS ----------------------------------------------------------------
  --  Vim Snippets engine  [snippet engine] + [snippet templates]
  --  https://github.com/L3MON4D3/LuaSnip
  --  https://github.com/rafamadriz/friendly-snippets
  {
    "L3MON4D3/LuaSnip",
    build = not is_windows and "make install_jsregexp" or nil,
    dependencies = {
      "rafamadriz/friendly-snippets",
      "zeioth/NormalSnippets",
      "benfowler/telescope-luasnip.nvim",
    },
    event = "User BaseFile",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
      region_check_events = "CursorMoved",
    },
    config = function(_, opts)
      if opts then require("luasnip").config.setup(opts) end
      vim.tbl_map(
        function(type) require("luasnip.loaders.from_" .. type).lazy_load() end,
        { "vscode", "snipmate", "lua" }
      )
      -- friendly-snippets - enable standardized comments snippets
      require("luasnip").filetype_extend("lua", { "luadoc" })
      require("luasnip").filetype_extend("python", { "pydoc" })
      require("luasnip").filetype_extend("sh", { "shelldoc" })
      require("go").filetype_extend("go", { "godoc" })
    end,
  },

  --  GIT ---------------------------------------------------------------------
  --  Git signs [git hunks]
  --  https://github.com/lewis6991/gitsigns.nvim
  {
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable("git") == 1,
    event = "User BaseGitFile",
    opts = function()
      local get_icon = require("base.utils").get_icon
      return {
        max_file_length = vim.g.big_file.lines,
        signs = {
          add = { text = get_icon("GitSign") },
          change = { text = get_icon("GitSign") },
          delete = { text = get_icon("GitSign") },
          topdelete = { text = get_icon("GitSign") },
          changedelete = { text = get_icon("GitSign") },
          untracked = { text = get_icon("GitSign") },
        },
      }
    end
  },

  --  Git fugitive mergetool + [git commands]
  --  https://github.com/lewis6991/gitsigns.nvim
  --  PR needed: Setup keymappings to move quickly when using this feature.
  --
  --  We only want this plugin to use it as mergetool like "git mergetool".
  --  To enable this feature, add this  to your global .gitconfig:
  --
  --  [mergetool "fugitive"]
  --  	cmd = nvim -c \"Gvdiffsplit!\" \"$MERGED\"
  --  [merge]
  --  	tool = fugitive
  --  [mergetool]
  --  	keepBackup = false
  {
    "tpope/vim-fugitive",
    enabled = vim.fn.executable("git") == 1,
    dependencies = { "tpope/vim-rhubarb" },
    cmd = {
      "Gvdiffsplit",
      "Gdiffsplit",
      "Gedit",
      "Gsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GRename",
      "GDelete",
      "GRemove",
      "GBrowse",
      "Git",
      "Gstatus",
    },
    config = function()
      -- NOTE: On vim plugins we use config instead of opts.
      vim.g.fugitive_no_maps = 1
    end,
  },

  --  ANALYZER ----------------------------------------------------------------
  --  [symbols tree]
  --  https://github.com/stevearc/aerial.nvim
  {
    "stevearc/aerial.nvim",
    event = "User BaseFile",
    opts = {
      filter_kind = { -- Symbols that will appear on the tree
        -- "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        -- "Module",
        "Method",
        -- "Struct",
      },
      open_automatic = false, -- Open if the buffer is compatible
      nerd_font = (vim.g.fallback_icons_enabled and false) or true,
      autojump = true,
      link_folds_to_tree = false,
      link_tree_to_folds = false,
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      disable_max_lines = vim.g.big_file.lines,
      disable_max_size = vim.g.big_file.size,
      layout = {
        min_width = 28,
        default_direction = "right",
        placement = "edge",
      },
      show_guides = true,
      guides = {
        mid_item = "├ ",
        last_item = "└ ",
        nested_top = "│ ",
        whitespace = "  ",
      },
      keymaps = {
        ["[y"] = "actions.prev",
        ["]y"] = "actions.next",
        ["[Y"] = "actions.prev_up",
        ["]Y"] = "actions.next_up",
        ["{"] = false,
        ["}"] = false,
        ["[["] = false,
        ["]]"] = false,
      },
    },
    config = function(_, opts)
      require("aerial").setup(opts)
      -- HACK: The first time you open aerial on a session, close all folds.
      vim.api.nvim_create_autocmd({"FileType", "BufEnter"}, {
        desc = "Aerial: When aerial is opened, close all its folds.",
        callback = function()
          local is_aerial = vim.bo.filetype == "aerial"
          local is_ufo_available = require("base.utils").is_available("nvim-ufo")
          if is_ufo_available and is_aerial and vim.b.new_aerial_session == nil then
            vim.b.new_aerial_session = false
            require("aerial").tree_set_collapse_level(0, 0)
          end
        end,
      })
    end
  },

  -- Litee calltree [calltree]
  -- https://github.com/ldelossa/litee.nvim
  -- https://github.com/ldelossa/litee-calltree.nvim
  -- press ? inside the panel to show help.
  {
    'ldelossa/litee.nvim',
    event = "User BaseFile",
    opts = {
      notify = { enabled = false },
      tree = {
          icon_set = "default" -- "nerd", "codicons", "default", "simple"
      },
      panel = {
          orientation = "bottom",
          panel_size = 10,
      },
    },
    config = function(_, opts)
      require('litee.lib').setup(opts)
    end
  },
  {
    'ldelossa/litee-calltree.nvim',
    dependencies = 'ldelossa/litee.nvim',
    event = "User BaseFile",
    opts = {
      on_open = "panel", -- or popout
      map_resize_keys = false,
      keymaps = {
        expand = "<CR>",
        collapse = "c",
        collapse_all = "C",
        jump = "<C-CR>"
      },
    },
    config = function(_, opts)
      require('litee.calltree').setup(opts)

      -- Highlight only while on calltree
      vim.api.nvim_create_autocmd({ "WinEnter" }, {
        desc = "Clear highlights when leaving calltree + UX improvements.",
        callback = function()
          vim.defer_fn(function()
            if vim.bo.filetype == "calltree" then
              vim.wo.colorcolumn = "0"
              vim.wo.foldcolumn = "0"
              vim.cmd("silent! PinBuffer") -- stickybuf.nvim
              vim.cmd("silent! hi LTSymbolJump ctermfg=015 ctermbg=110 cterm=italic,bold,underline guifg=#464646 guibg=#87afd7 gui=italic,bold")
              vim.cmd("silent! hi LTSymbolJumpRefs ctermfg=015 ctermbg=110 cterm=italic,bold,underline guifg=#464646 guibg=#87afd7 gui=italic,bold")
            else
              vim.cmd("silent! highlight clear LTSymbolJump")
              vim.cmd("silent! highlight clear LTSymbolJumpRefs")
            end
          end, 100)
        end
      })
    end
  },

  --  CODE DOCUMENTATION ------------------------------------------------------
  --  dooku.nvim [html doc generator]
  --  https://github.com/zeioth/dooku.nvim
  {
    "zeioth/dooku.nvim",
    cmd = {
      "DookuGenerate",
      "DookuOpen",
      "DookuAutoSetup"
    },
    opts = {},
  },

  --  [markdown previewer]
  --  https://github.com/iamcco/markdown-preview.nvim
  --  Note: If you change the build command, wipe ~/.local/data/nvim/lazy
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    ft = { "markdown" },
    cmd = {
      "MarkdownPreview",
      "MarkdownPreviewStop",
      "MarkdownPreviewToggle",
    },
  },

  --  [markdown markmap]
  --  https://github.com/zeioth/markmap.nvim
  --  Important: Make sure you have yarn in your PATH before running markmap.
  {
    "zeioth/markmap.nvim",
    build = "yarn global add markmap-cli",
    cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
    config = function(_, opts) require("markmap").setup(opts) end,
  },

  --  ARTIFICIAL INTELLIGENCE  -------------------------------------------------
  --  neural [chatgpt code generator]
  --  https://github.com/dense-analysis/neural
  --
  --  NOTE: In order for this plugin to work, you will have to set
  --        the next env var in your OS:
  --        OPENAI_API_KEY="my_key_here"

  --   "dense-analysis/neural",
  --   cmd = { "Neural" },
  --   config = function()
  --     require("neural").setup {
  --       source = {
  --         openai = {
  --           api_key = vim.env.OPENAI_API_KEY,
  --         },
  --       },
  --       ui = {
  --         prompt_icon = require("base.utils").get_icon("PromptPrefix"),
  --       },
  --     }
  --   end,
  -- },

  --  copilot [github code suggestions]
  --  https://github.com/github/copilot.vim
  --  As alternative to chatgpt, you can use copilot uncommenting this.
  --  Then you must run :Copilot setup
  {
    "github/copilot.vim",
    event = "User BaseFile"
  },
  -- copilot-cmp
  -- https://github.com/zbirenbaum/copilot-cmp
  {
    "zbirenbaum/copilot-cmp",
    opts = { suggesion = { enabled = false }, panel = { enabled = false } },
    config = function (_, opts) require("copilot_cmp").setup(opts) end
  },

  -- [guess-indent]
  -- https://github.com/NMAC427/guess-indent.nvim
  -- Note that this plugin won't autoformat the code.
  -- It just set the buffer options to tabluate in a certain way.
  {
    "NMAC427/guess-indent.nvim",
    event = "User BaseFile",
    opts = {}
  },

  --  COMPILER ----------------------------------------------------------------
  --  compiler.nvim [compiler]
  --  https://github.com/zeioth/compiler.nvim
  {
    "zeioth/compiler.nvim",
    cmd = {
      "CompilerOpen",
      "CompilerToggleResults",
      "CompilerRedo",
      "CompilerStop"
    },
    dependencies = { "stevearc/overseer.nvim" },
    opts = {},
  },

  --  overseer [task runner]
  --  https://github.com/stevearc/overseer.nvim
  --  If you need to close a task immediately:
  --  press ENTER in the output menu on the task you wanna close.
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerInfo",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache"
    },
    opts = {
     task_list = { -- the window that shows the results.
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
      -- component_aliases = {
      --   default = {
      --     -- Behaviors that will apply to all tasks.
      --     "on_exit_set_status",                   -- don't delete this one.
      --     "on_output_summarize",                  -- show last line on the list.
      --     "display_duration",                     -- display duration.
      --     "on_complete_notify",                   -- notify on task start.
      --     "open_output",                          -- focus last executed task.
      --     { "on_complete_dispose", timeout=300 }, -- dispose old tasks.
      --   },
      -- },
    },
  },

  --  DEBUGGER ----------------------------------------------------------------
  --  Debugger alternative to vim-inspector [debugger]
  --  https://github.com/mfussenegger/nvim-dap
  --  Here we configure the adapter+config of every debugger.
  --  Debuggers don't have system dependencies, you just install them with mason.
  --  We currently ship most of them with nvim.
  {
    "mfussenegger/nvim-dap",
    enabled = vim.fn.has "win32" == 0,
    event = "User BaseFile",
    config = function()
      local dap = require("dap")

      -- C#
      dap.adapters.coreclr = {
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/bin/netcoredbg',
        args = { '--interpreter=vscode' }
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function() -- Ask the user what executable wants to debug
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Program.exe', 'file')
          end,
        },
      }

      -- Python
      dap.adapters.python = {
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
        args = { '-m', 'debugpy.adapter' },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}", -- This configuration will launch the current file if used.
        },
      }

      -- Lua
      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
      end
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = "Attach to running Neovim instance",
          program = function() pcall(require "osv".launch({ port = 8086 })) end,
        }
      }

      -- Go
      -- Requires:
      -- * You have initialized your module with 'go mod init module_name'.
      -- * You :cd your project before running DAP.
      dap.adapters.delve = {
        type = 'server',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath('data') .. '/mason/packages/delve/dlv',
          args = { 'dap', '-l', '127.0.0.1:${port}' },
        }
      }
      dap.configurations.go = {
        {
          type = "delve",
          name = "Compile module and debug this file",
          request = "launch",
          program = "./${relativeFileDirname}",
        },
        {
          type = "delve",
          name = "Compile module and debug this file (test)",
          request = "launch",
          mode = "test",
          program = "./${relativeFileDirname}"
        },
      }

      -- PHP
      dap.adapters.php = {
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/bin/php-debug-adapter',
      }
      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Listen for Xdebug',
          port = 9000
        }
      }

      -- Shell
      dap.adapters.bashdb = {
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/bash-debug-adapter',
        name = 'bashdb',
      }
      dap.configurations.sh = {
        {
          type = 'bashdb',
          request = 'launch',
          name = "Launch file",
          showDebugOutput = true,
          pathBashdb = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
          pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
          trace = true,
          file = "${file}",
          program = "${file}",
          cwd = '${workspaceFolder}',
          pathCat = "cat",
          pathBash = "/bin/bash",
          pathMkfifo = "mkfifo",
          pathPkill = "pkill",
          args = {},
          env = {},
          terminalKind = "integrated",
        }
      }

    end, -- of dap config
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "rcarriga/cmp-dap",
      "jay-babu/mason-nvim-dap.nvim",
      "jbyuki/one-small-step-for-vimkind",
    },
  },

  -- nvim-dap-ui [dap ui]
  -- https://github.com/mfussenegger/nvim-dap-ui
  -- user interface for the debugger dap
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    opts = { floating = { border = "rounded" } },
    config = function(_, opts)
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function(
      )
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function(
      )
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      dapui.setup(opts)
    end,
  },

  -- cmp-dap [dap autocomplete]
  -- https://github.com/mfussenegger/cmp-dap
  -- Enables autocomplete for the debugger dap.
  {
    "rcarriga/cmp-dap",
    dependencies = { "nvim-cmp" },
    config = function()
      require("cmp").setup.filetype(
        { "dap-repl", "dapui_watches", "dapui_hover" },
        {
          sources = {
            { name = "dap" },
          },
        }
      )
    end,
  },

  --  TESTING -----------------------------------------------------------------
  --  Run tests inside of nvim [unit testing]
  --  https://github.com/nvim-neotest/neotest
  --
  --
  --  MANUAL:
  --  -- Unit testing:
  --  To tun an unit test you can run any of these commands:
  --
  --    :Neotest run      -- Runs the nearest test to the cursor.
  --    :Neotest stop     -- Stop the nearest test to the cursor.
  --    :Neotest run file -- Run all tests in the file.
  --
  --  -- E2e and Test Suite
  --  Normally you will prefer to open your e2e framework GUI outside of nvim.
  --  But you have the next commands in ../base/3-autocmds.lua:
  --
  --    :TestNodejs    -- Run all tests for this nodejs project.
  --    :TestNodejsE2e -- Run the e2e tests/suite for this nodejs project.
  {
    "nvim-neotest/neotest",
    cmd = { "Neotest" },
    dependencies = {
      "fredrikaverpil/neotest-golang",
      "olimorris/neotest-phpunit",
      "nvim-neotest/neotest-python",
    },
    opts = function()
      return {
        -- your neotest config here
        adapters = {
          require("neotest-golang"),
          require("neotest-phpunit"),
          require("neotest-python"),
        },
      }
    end,
    config = function(_, opts)
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace "neotest"
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)
      require("neotest").setup(opts)
    end,
  },

  --  Shows a float panel with the [code coverage]
  --  https://github.com/andythigpen/nvim-coverage
  --
  --  Your project must generate coverage/lcov.info for this to work.
  --
  --  On jest, make sure your packages.json file has this:
  --  "tests": "jest --coverage"
  --
  --  If you use other framework or language, refer to nvim-coverage docs:
  --  https://github.com/andythigpen/nvim-coverage/blob/main/doc/nvim-coverage.txt
  {
    "zeioth/nvim-coverage", -- Our fork until all our PRs are merged.
    cmd = {
      "Coverage",
      "CoverageLoad",
      "CoverageLoadLcov",
      "CoverageShow",
      "CoverageHide",
      "CoverageToggle",
      "CoverageClear",
      "CoverageSummary",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      summary = {
        min_coverage = 80.0, -- passes if higher than
      },
    },
    config = function(_, opts) require("coverage").setup(opts) end,
  },

  -- LANGUAGE IMPROVEMENTS ----------------------------------------------------
  -- guttentags_plus [auto generate C/C++ tags]
  -- https://github.com/skywind3000/gutentags_plus
  -- This plugin is necessary for using <C-]> (go to ctag).
  {
    "skywind3000/gutentags_plus",
    ft = { "c", "cpp", "lisp" },
    dependencies = { "ludovicchabant/vim-gutentags" },
    config = function()
      -- NOTE: On vimplugins we use config instead of opts.
      vim.g.gutentags_plus_nomap = 1
      vim.g.gutentags_resolve_symlinks = 1
      vim.g.gutentags_cache_dir = vim.fn.stdpath "cache" .. "/tags"
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Auto generate C/C++ tags",
        callback = function()
          local is_c = vim.bo.filetype == "c" or vim.bo.filetype == "cpp"
          if is_c then vim.g.gutentags_enabled = 1
          else vim.g.gutentags_enabled = 0 end
        end,
      })
    end,
  },

} -- end of return
