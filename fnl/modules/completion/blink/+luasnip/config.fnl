(import-macros {: set!
                : nyoom-module-p!
                : packadd!
                : command!
                : build-before-all-hook} :macros)

(local {: autoload} (require :core.lib.autoload))
(local {: setup} (require :core.lib.setup))
(local luasnip (autoload :luasnip))
((. (autoload :luasnip.loaders.from_vscode) :lazy_load))

; (build-before-all-hook :luasnip [:make :install]
;                        :target/release/libparinfer_rust.so)

(packadd! luasnip)

(local types (require :luasnip.util.types))

(local opts {:delete_check_events :TextChanged
             :ext_opts {types.exitNode {:unvisited {:virt_text [["|" :Conceal]]}}
                        types.insertNode {:unvisited {:virt_text [["|"
                                                                   :Conceal]]}}}
             :history true})

(setup :luasnip opts)

(vim.keymap.set :i :<C-j> (fn []
                            (or (and ((. (require :luasnip) :jumpable) 1)
                                     :<Plug>luasnip-jump-next)
                                :<C-j>))
                {:expr true :remap true :silent true})

(vim.keymap.set :s :<C-j>
                (fn []
                  ((. (require :luasnip) :jump) 1)))

(vim.keymap.set [:i :s] :<C-k>
                (fn []
                  ((. (require :luasnip) :jump) (- 1))))

(local vs (require :luasnip.loaders.from_vscode))
(local lu (require :luasnip.loaders.from_lua))

(lu.lazy_load {:paths (.. (vim.fn.stdpath :config) :/snippets/lua)})
(vs.lazy_load {:paths (.. (vim.fn.stdpath :config) :/snippets/vs)})

(vs.lazy_load)

(command! LuaSnipEdit
          (fn []
            ((. (require :luasnip.loaders) :edit_snippet_files))) {})

