local ls = require "luasnip"
local s = ls.snippet
local f = ls.function_node
-- local sn = ls.snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local c = ls.choice_node

local uuid = function()
  local u = require "uuid"
  return u()
end

local date = function()
  return { os.date "%Y-%m-%d" }
end

local filename = function()
  return { vim.fn.expand "%:p" }
end

return {
  s("filename", {
    f(filename),
  }),

  s("uuid", {
    f(uuid),
  }),

  s("date", {
    f(date, {}),
  }),
}
