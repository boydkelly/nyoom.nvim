(import-macros {: nyoom-module! : build-pack-table : build-before-all-hook} :macros)

(nyoom-module! editor.scratch)
; (ab)using lz-package! for lazy-loading
;; (lz-package! :editor.scratch {:after editor.scratch
                               ; :cmd :Scratch)
