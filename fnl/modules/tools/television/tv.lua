return {
  "tv.nvim",
  lazy = true,
  cmd = { "Tv" },

-- stylua: ignore start
  keys = {
    { "<leader>sma", "<cmd>Tv mandenkan-all<cr>", desc = "Mandenkan all" },
    { "<leader>smc", "<cmd>Tv mandenkan-cours<cr>", desc = "Mandenkan cours" },
    { "<leader>smd", "<cmd>Tv mandenkan-dico<cr>", desc = "Mandenkan dico" },
    { "<leader>smp", "<cmd>Tv mandenkan-docs<cr>", desc = "Mandenkan docs" },
    { "<leader>smw", "<cmd>Tv mandenkan-wt<cr>", desc = "Mandenkan wt" },
    { "<leader>fd", function() vim.cmd.Tv("dotfiles") end, desc = "Dotfiles" },
    { "<leader>fc", function() vim.cmd.Tv("neovim") end, desc = "Neovim files" },
    -- { "<leader>ff", function() vim.cmd.Tv("files") end, desc = "Search files" },
    { "<leader>st", function() vim.cmd.Tv("text") end, desc = "Grep Text" },
    { "<leader>su", function() vim.cmd.Tv("unicode") end, desc = "Insert Unicode" },
  },
  -- stylua: ignore end
  after = function()
    require "setup.tv"
  end,
}
