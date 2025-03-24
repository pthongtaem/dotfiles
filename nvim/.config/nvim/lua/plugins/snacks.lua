return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true, -- Enable hidden files in fuzzy finder
          -- ignored = true,
        },
        explorer = {
          hidden = true, -- Enable hidden files in file explorer
          -- ignored = true,
        },
        grep = {
          hidden = true, -- Enable hidden files in file explorer
          -- ignored = true,
        },
      },
    },
  },
}
