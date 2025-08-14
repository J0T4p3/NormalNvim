return {
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
    },
    config = function()
      require("go").setup({
        goimport = "gopls",
        gofmt = "gofumpt",
        tag_transform = false,
        test_dir = "",
        comment_placeholder = "   ",
        lsp_cfg = false, -- Don't override LSP config
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
  },
}
