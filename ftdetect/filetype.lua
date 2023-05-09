vim.filetype.add {
  extension = {
    ["xdxf"] = "xml",
    ["pcss"] = "css",
    [{ "fcc", "yml" }] = "yaml",
  },
  pattern = {
    [".html"] = {
      priority = -math.huge,
      function(bufnr)
        local content = vim.filetype.getlines(bufnr, -1)
        if vim.filetype.matchregex(content, [[{{]]) then
          return "gothmltmpl"
        end
      end,
    },
  },
}
