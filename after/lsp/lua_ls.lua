-- :fennel:1771176034
local blink_ok, blink = pcall(require, "blink.cmp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
if blink_ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
else
end
return {capabilities = capabilities, cmd = {"lua-language-server"}, filetypes = {"lua"}, flags = {debounce_text_changes = 300}, root_markers = {".luarc.json", ".luarc.jsonc", ".jj", ".git"}, settings = {Lua = {diagnostics = {globals = {"vim"}}, hint = {enable = true}, runtime = {version = "LuaJIT"}, telemetry = {enable = false}, workspace = {library = {vim.env.VIMRUNTIME}, maxPreload = 1000, preloadFileSize = 100, checkThirdParty = false}}}}