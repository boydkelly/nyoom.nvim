local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local isn = ls.indent_snippet_node

local uuid = function()
  local u = require "uuid"
  return u()
end

return {
  s("isn", {
    isn(5, {
      t { "This is indented as deep as the trigger", "and this is at the beginning of the next line" },
    }, ""),
  }),
  s("key4", {
    isn(1, {
      t {
        "This is indented as deep as the trigger",
        "and this is at the beginning of the next line",
      },
    }, ""),

    t { " - k:", "     +content: " },
    i(1, "source"),
    t { "", "     +@xml:lang: dyu" },
    t { "", "   def:" },
    t { "", "     def:" },
    t { "", "       +@xml:lang: fr" },
    t { "", "       def:" },
    t { "", "         - +@def-id: " },
    f(uuid),
    t { "", "           gr:" },
    t { "", "             abbr: " },
    i(2, "pos"),
    t { "", "           def:" },
    t { "", "             - +@def-id: " },
    f(uuid),
    t { "", "               deftext: " },
    i(3, "target"),
    t { "", "               ex:" },
    t { "", "                 - +@type: exm" },
    t { "", "                   +@ex-id: " },
    f(uuid),
    t { "", "                   ex_orig: " },
    i(4, "origin ex"),
    t { "", "                   ex_tran: " },
    i(5, "trans ex"),
    t { "", "               sr:" },
    t { "", "                 kref:" },
    t { "", "                   - +content: " },
    i(6, "synonym"),
    t { "", "                     +@type: syn" },
    t { "", "               categ:" },
    t { "", "     sr:" },
    t { "", "       kref:" },
    t { "", "         - +content: " },
    i(7, "ortho"),
    t { "", "           +@type: spv", "" },
    i(0),
  }),
  s("exm", {
    t { "", "               ex:" },
    t { "", "                 - +@type: exm" },
    t { "", "                   +@ex-id: " },
    f(uuid),
    t { "", "                   ex_orig: " },
    i(4, "origin ex"),
    t { "", "                   ex_tran: " },
    i(5, "trans ex"),
    i(0),
  }),

  s("key3", {
    t { " - k:", "     +content: " },
    i(1, "source"),
    t { "", "     +@xml:lang: dyu" },
    t { "", "   def:" },
    t { "", "     def:" },
    t { "", "       +@xml:lang: fr" },
    t { "", "       def:" },
    t { "", "         - +@def-id: " },
    f(uuid),
    t { "", "           gr:" },
    t { "", "             abbr: " },
    i(2, "pos"),
    t { "", "           def:" },
    t { "", "             - +@def-id: " },
    f(uuid),
    t { "", "               deftext: " },
    i(3, "target"),
    t { "", "               ex:" },
    t { "", "                 - +@type: exm" },
    t { "", "                   +@ex-id: " },
    f(uuid),
    t { "", "                   ex_orig: " },
    i(4, "origin ex"),
    t { "", "                   ex_tran: " },
    i(5, "trans ex"),
    t { "", "               sr:" },
    t { "", "                 kref:" },
    t { "", "                   - +content: " },
    i(6, "synonym"),
    t { "", "                     +@type: syn" },
    t { "", "               categ:" },
    t { "", "     sr:" },
    t { "", "       kref:" },
    t { "", "         - +content: " },
    i(7, "ortho"),
    t { "", "           +@type: spv", "" },
    i(0),
  }),

  s("key2", {
    t {
      " - k:",
      "     +content: ",
      "     +@xml:lang: dyu",
      "   def:",
      "     def:",
      "       +@xml:lang: fr",
      "       def:",
      "         - +@def-id: f(uuid)",
      "           gr:",
      "             abbr: ",
      "           def:",
      "             - +@def-id: uuid",
      "               deftext: $2",
      "               ex:",
      "                 +@type: exm",
      "                 +@ex-id: uuid",
      "                 ex_orig:",
      "                 ex_tran:",
      "               sr:",
      "                 kref:",
      "                   - +content: $3",
      "                     +@type: syn",
      "     sr:",
      "       kref:",
      "         - +content: $4",
      "           +@type: spv",
    },
  }),
}
