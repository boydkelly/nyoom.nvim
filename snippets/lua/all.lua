-- stylua: ignore
local ls = require "luasnip"
local s, f, t, i = ls.snippet, ls.function_node, ls.text_node, ls.insert_node

-- stylua: ignore start
local card = function()
  return {
    t "-", -- first line
    t { "", "nickname: " },         i(1),
    t { "", "cardholder_name: " },  i(2, "Boyd Kelly"),
    t { "", "issuer: " },           i(3),
    t { "", "type: " },             i(4),
    t { "", "number: " },           i(5, "0000"), t(" "), i(6, "0000"), t(" "), i(7, "0000"), t(" "), i(8, "0000"),
    t { "", "last4: " },            i(9, "0000"),
    t { "", "expiry: " },           i(10, "00/00"),
    t { "", "cvv: " },              i(11, "000"),
    t { "", "phone_loss: " },       i(12),
    t { "", "credit_limit: " },     i(13),
    t { "", "notes: " },            i(14),
  }
end

return {
  s("card", card()),
  s("filename", { f(function() return vim.fn.expand("%:p") end) }),
  s("uuid", { f(function() return require("utils.uuid")() end) }),
  s("date", { f(function() return os.date("%Y-%m-%d") end) }),
}
-- stylua: ignore end
