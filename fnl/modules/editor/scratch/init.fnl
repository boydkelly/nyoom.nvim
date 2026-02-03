(import-macros {: fake-module! : vim-pack-spec!} :macros)

(fake-module! editor.scratch)
; (ab)using lz-package! for lazy-loading
;; (lz-package! :editor.scratch {:after editor.scratch
                               ; :cmd :Scratch)
