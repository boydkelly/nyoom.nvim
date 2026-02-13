(local {: autoload} (require :core.lib.autoload))
(local shared (require :core.lib.shared))
(import-macros {: nyoom-module-p! : nyoom-module-ensure! : packadd!} :macros)
(packadd! :none-ls)
(local none-ls (require :null-ls))
(local none-ls-sources [])

;(nyoom-module-ensure! lsp)

; moved to tools.lsp
; (vim.diagnostic.config {:underline {:severity {:min vim.diagnostic.severity.INFO}}
;                         :signs {:severity {:min vim.diagnostic.severity.HINT}}
;                         :virtual_text false
;                         :float {:show_header false
;                                 :source true}
;                         :update_in_insert false
;                         :severity_sort true})

(fn on-attach [client buf]
  ;; This only runs if none-ls attaches to a buffer
  (nyoom-module-p! config.+bindings
                   (do
                     (local {:open_float open-line-diag-float!
                             :goto_prev goto-diag-prev!
                             :goto_next goto-diag-next!}
                            vim.diagnostic)
                     (map! [n] :<leader>d open-line-diag-float!
                           {:buffer buf :desc "Open diagnostics"})
                     (map! [n] "[d" goto-diag-prev!
                           {:buffer buf :desc "Prev diagnostic"})
                     (map! [n] "]d" goto-diag-next!
                           {:buffer buf :desc "Next diagnostic"}))))

(nyoom-module-p! format
                 (do
                   ;; (table.insert none-ls-sources none-ls.builtins.formatting.fnlfmt)
                   (nyoom-module-p! cc
                                    (table.insert none-ls-sources
                                                  none-ls.builtins.formatting.clang_format))
                   (nyoom-module-p! clojure
                                    (table.insert none-ls-sources
                                                  none-ls.builtins.formatting.zprint))
                   (nyoom-module-p! java
                                    (table.insert none-ls-sources
                                                  none-ls.builtins.formatting.google_java_format))
                   (nyoom-module-p! kotlin
                                    (table.insert none-ls-sources
                                                  none-ls.builtins.formatting.ktlint))
                   (nyoom-module-p! lua
                                    (table.insert none-ls-sources
                                                  none-ls.builtins.formatting.stylua))
                   (nyoom-module-p! markdown
                                    (table.insert none-ls-sources
                                                  none-ls.builtins.formatting.markdownlint))
                   (nyoom-module-p! nim
                                    (table.insert none-ls-sources
                                                  none-ls.builtins.formatting.nimpretty))
                   (nyoom-module-p! python
                                    (do
                                      (table.insert none-ls-sources
                                                    none-ls.builtins.formatting.black)
                                      (table.insert none-ls-sources
                                                    none-ls.builtins.formatting.isort)))))

; now handled by lsp
; (nyoom-module-p! rust
;                  (table.insert none-ls-sources
;                                none-ls.builtins.formatting.rustfmt))
; handled by lsp natively that calls shfmt
; (nyoom-module-p! sh
;                  (table.insert none-ls-sources
;                                none-ls.builtins.formatting.shfmt))
; handled by zls
; (nyoom-module-p! zig
;                  (table.insert none-ls-sources
;                                none-ls.builtins.formatting.zigfmt))

; handeled by diagnostics virtual_lines setting
; (nyoom-module-p! diagnostics
;                  (do
;                    (nyoom-module-p! lua
;                                     (table.insert none-ls-sources
;                                                   none-ls.builtins.diagnostics.selene))))

(nyoom-module-p! vc-gutter
                 (table.insert none-ls-sources
                               none-ls.builtins.code_actions.gitsigns))

(none-ls.setup {:sources none-ls-sources
                ;; #{m}: message
                ;; #{s}: source name (defaults to none-ls if not specified)
                ;; #{c}: code (if available
                :diagnostics_format "[#{c}] #{m} (#{s})"
                :debug true
                :on_attach on-attach})
