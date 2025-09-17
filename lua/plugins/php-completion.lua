return {
  -- Enhanced autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- LSP completion source
      "hrsh7th/cmp-nvim-lsp",
      -- Additional completion sources
      "hrsh7th/cmp-buffer",      -- Buffer completions
      "hrsh7th/cmp-path",        -- Path completions
      "hrsh7th/cmp-cmdline",     -- Command line completions
      "hrsh7th/cmp-nvim-lua",    -- Neovim Lua API
      -- Snippet engine and completions
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets", -- Snippet collection
      -- PHP-specific completion enhancements
      "hrsh7th/cmp-nvim-lsp-signature-help", -- Function signatures
      "hrsh7th/cmp-nvim-lsp-document-symbol", -- Document symbols
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      -- Load friendly snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          -- Navigate completion items
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          -- Scroll documentation
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          -- Trigger completion
          ["<C-Space>"] = cmp.mapping.complete(),
          -- Close completion
          ["<C-e>"] = cmp.mapping.abort(),
          -- Confirm selection
          ["<CR>"] = cmp.mapping.confirm({ 
            behavior = cmp.ConfirmBehavior.Replace,
            select = false 
          }),
          -- Enhanced Tab behavior
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          -- High priority sources
          { name = "nvim_lsp", priority = 1000 },
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 800 },
        }, {
          -- Medium priority sources
          { name = "buffer", priority = 500, keyword_length = 3 },
          { name = "path", priority = 400 },
        }, {
          -- Low priority sources (only when others don't match)
          { name = "nvim_lsp_document_symbol", priority = 300, keyword_length = 3 },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- Kind icons
            local icons = {
              Text = "󰉿",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰜢",
              Variable = "󰀫",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "󰑭",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "󰈇",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "󰙅",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "",
            }
            vim_item.kind = string.format("%s %s", icons[vim_item.kind] or "", vim_item.kind)
            -- Source indicators
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              nvim_lsp_signature_help = "[Sig]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
              nvim_lsp_document_symbol = "[Sym]",
              nvim_lua = "[Lua]",
            })[entry.source.name] or "[?]"
            -- Truncate long items
            if string.len(vim_item.abbr) > 40 then
              vim_item.abbr = string.sub(vim_item.abbr, 1, 37) .. "..."
            end
            return vim_item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "Comment",
          },
        },
        -- PHP-specific completion behavior
        completion = {
          keyword_length = 1,
          keyword_pattern = [[\k\+]],
        },
        -- Better matching for PHP
        matching = {
          disallow_fuzzy_matching = false,
          disallow_fullfuzzy_matching = false,
          disallow_partial_fuzzy_matching = false,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
        },
      })

      -- Command line completion
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        }),
      })

      -- Search completion
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        },
      })

      -- Auto-pairs for PHP
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Auto-pairs for PHP brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true, -- Enable treesitter integration
        ts_config = {
          php = { "string", "template_string" },
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        disable_in_macro = true,
        disable_in_visualblock = false,
        disable_in_replace_mode = true,
        ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
        enable_moveright = true,
        enable_afterquote = true,
        enable_check_bracket_line = false,
        enable_bracket_in_quote = true,
        enable_abbr = false,
        break_undo = true,
        check_comma = true,
        map_cr = true,
        map_bs = true,
        map_c_h = false,
        map_c_w = false,
      })
      -- PHP-specific rules
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")
      -- PHP opening tags
      autopairs.add_rules({
        Rule("<?", "?>", "php"):with_pair(cond.not_after_regex("%w")),
        Rule("<?php", " ?>", "php"):with_pair(cond.not_after_regex("%w")),
      })
    end,
  },

  -- Enhanced snippets for PHP
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp", -- Optional: for advanced regex features
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")
      ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged",
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = {
              virt_text = { { "choiceNode", "Comment" } },
            },
          },
        },
        ext_base_prio = 300,
        ext_prio_increase = 1,
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
        ft_func = function()
          return vim.split(vim.bo.filetype, ".", { plain = true })
        end,
      })
      -- Keymaps for snippet navigation
      vim.keymap.set({"i", "s"}, "<C-l>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true, desc = "Expand or jump snippet" })
      vim.keymap.set({"i", "s"}, "<C-h>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true, desc = "Jump back in snippet" })
      vim.keymap.set("i", "<C-k>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "Change snippet choice" })
    end,
  },
}
