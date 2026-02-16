(local (blink-ok blink) (pcall require :blink.cmp))

(var capabilities (vim.lsp.protocol.make_client_capabilities))

(when blink-ok
  (set capabilities (blink.get_lsp_capabilities capabilities)))

{: capabilities
 :cmd [:lua-language-server]
 :filetypes [:lua]
 :flags {:debounce_text_changes 300}
 :root_markers [:.luarc.json :.luarc.jsonc :.jj :.git]
 :settings {:Lua {:diagnostics {:globals [:vim]}
                  :hint {:enable true}
                  :runtime {:version :LuaJIT}
                  :telemetry {:enable false}
                  :workspace {:checkThirdParty false
                              :library [vim.env.VIMRUNTIME]
                              :maxPreload 1000
                              :preloadFileSize 100}}}}

