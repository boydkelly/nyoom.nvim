(import-macros {: packadd! : set! : map! : nyoom-module-ensure!} :macros)

(nyoom-module-ensure! tree-sitter)

(set! foldenable true)
(set! foldmethod "expr")
(set! foldexpr "v:lua.vim.treesitter.foldexpr()")
(set! foldopen "block,mark,percent,quickfix,search,tag,undo")
(set! foldcolumn "1")
(set! foldlevel 99)
(set! foldtext "")

(set vim.opt.fillchars {:eob " "
                        :fold " "
                        :foldclose "▶"
                        :foldopen "▼"
                        :foldsep " "})

; (map! [n] :zR `(openAllFolds) {:desc "Open all folds"})
; (map! [n] :zM `(closeAllFolds {:desc "Close all folds"}))
