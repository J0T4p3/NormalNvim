return {
  -- Seamless navigation between tmux panes and vim splits
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  -- Send commands to tmux panes
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_default_config = {
        socket_name = "default",
        target_pane = "1",
      }
      vim.g.slime_dont_ask_default = 1
      vim.g.slime_no_mappings = 1
    end,
    keys = {
      { "<leader>ss", "<Plug>SlimeLineSend", desc = "Send line to tmux" },
      { "<leader>ss", "<Plug>SlimeRegionSend", mode = "v", desc = "Send selection to tmux" },
      { "<leader>sc", "<Plug>SlimeConfig", desc = "Configure slime target" },
    },
  },

  -- Optional: Better tmux integration with additional features
  {
    "aserowy/tmux.nvim",
    event = "VeryLazy",
    opts = {
      copy_sync = {
        -- Enable copying to system clipboard
        enable = true,
        ignore_buffers = { empty = false },
        redirect_to_clipboard = false,
        register_offset = 0,
        sync_clipboard = true,
        sync_registers = true,
        sync_deletes = true,
        sync_unnamed = true,
      },
      navigation = {
        -- Enable smart navigation
        cycle_navigation = true,
        enable_default_keybindings = false, -- We'll set custom ones
        persist_zoom = false,
      },
      resize = {
        -- Enable smart resizing
        enable_default_keybindings = false,
        resize_step_x = 2,
        resize_step_y = 1,
      },
    },
    keys = {
      -- Navigation (alternative to vim-tmux-navigator)
      { "<C-h>", function() require("tmux").move_left() end, desc = "Move to left pane" },
      { "<C-j>", function() require("tmux").move_bottom() end, desc = "Move to bottom pane" },
      { "<C-k>", function() require("tmux").move_top() end, desc = "Move to top pane" },
      { "<C-l>", function() require("tmux").move_right() end, desc = "Move to right pane" },

      -- Resizing
      { "<A-h>", function() require("tmux").resize_left() end, desc = "Resize left" },
      { "<A-j>", function() require("tmux").resize_bottom() end, desc = "Resize down" },
      { "<A-k>", function() require("tmux").resize_top() end, desc = "Resize up" },
      { "<A-l>", function() require("tmux").resize_right() end, desc = "Resize right" },
    },
  },
}
