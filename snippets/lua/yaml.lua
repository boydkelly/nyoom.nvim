local ls = require "luasnip"
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local isn = ls.indent_snippet_node

local uuid = function()
  local u = require "utils.uuid"
  return u()
end

local set_col = function()
  -- local original_cursor = vim.fn.winsaveview()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  print("col:", col)
  print("col:", col + 7)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
end

return {
  s("isn1", {
    isn(5, {
      t { "This is indented as deep as the trigger", "and this is at the beginning of the next line" },
    }, ""),
  }),

  s("isn2", {
    isn(10, {
      t {
        "This is indented as deep as the trigger",
        "and this is at the beginning of the next line",
      },
      t { "", " - k:", "     +content: " },
      i(1, "source"),
    }, ""),

    t { "", "     +@xml:lang: dyu" },
    t { "", "   def:" },
    t { "", "     def:" },
    t { "", "       - +@xml:lang: fr" },
    t { "", "         def:" },
    t { "", "           - gr:" },
    t { "", "               - abbr:" },
    t { "", "             co:" },
    t { "", "               +content:" },
    f(uuid),
    t { "", "               +@type: uuid" },
    i(2, "pos"),
    t { "", "             def:" },
    t { "", "                - co:" },
    t { "", "                    +content:" },
    f(uuid),
    t { "", "                    +@type: uuid" },
    t { "", "                      deftext: " },
    i(3, "target"),
    t { "", "                      ex:" },
    t { "", "                        - +@type: exm" },
    t { "", "                          +@ex-id: " },
    f(uuid),
    t { "", "                          ex_orig: " },
    i(4, "origin ex"),
    t { "", "                          ex_tran: " },
    i(5, "trans ex"),
    t { "", "                      sr:" },
    t { "", "                        kref:" },
    t { "", "                          - +content: " },
    i(6, "synonym"),
    t { "", "                            +@type: syn" },
    t { "", "     sr:" },
    t { "", "       kref:" },
    t { "", "         - +content: " },
    i(7, "ortho"),
    t { "", "           +@type: spv", "" },
    i(0),
  }),

  s("exm", {
    t { "", "                      ex:" },
    t { "", "                        - +@type: exm" },
    t { "", "                          +@ex-id: " },
    f(uuid),
    t { "", "                          ex_orig: " },
    i(4, "origin ex"),
    t { "", "                          ex_tran: " },
    i(5, "trans ex"),
    i(0),
  }),

  s("exm2", {
    f(set_col),
    t {
      "               ex:",
      "                 - +@type: exm",
      "                   +@ex-id: ",
    },
    f(uuid),
    t { "", "                   ex_orig: " },
    i(4, "origin ex"),
    t { "", "                   ex_tran: " },
    i(5, "trans ex"),
    i(0),
  }),

  s("key", {
    t { "      - k:", "          +content: " },
    i(1, "source"),
    t {
      "",
      "          +@xml:lang: dyu",
      "        def:",
      "          def:",
      "            - +@xml:lang: fr",
      "              def:",
      "                - gr:",
      "                    - abbr: ",
    },
    i(2, "pos"),
    t { "", "                  co:" },
    t { "", "                    +content: " },
    f(uuid),
    t { "", "                    +@type: uuid" },
    t { "", "                  def:" },
    t { "", "                    - co:" },
    t { "", "                        +content: " },
    f(uuid),
    t { "", "                        +@type: uuid" },
    t { "", "                      deftext: " },
    i(3, "target"),
    t { "", "                      ex:" },
    t { "", "                        - +@type: exm" },
    t { "", "                          +@ex-id: " },
    f(uuid),
    t { "", "                          ex_orig: " },
    i(4, "origin ex"),
    t { "", "                          ex_tran: " },
    i(5, "trans ex"),
    t { "", "                      sr:" },
    t { "", "                        kref:" },
    t { "", "                          - +content: " },
    i(6, "synonym"),
    t { "", "                            +@type: syn" },
    t { "", "                      categ:" },
    t { "", "          sr:" },
    t { "", "            kref:" },
    t { "", "              - +content: " },
    i(7, "ortho"),
    t { "", "                +@type: spv", "" },
    i(0),
  }),
}
