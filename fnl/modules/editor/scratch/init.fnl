(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; (ab)using lz-package! for lazy-loading
(lz-package! :editor.scratch {:after editor.scratch
                               :cmd :Scratch})
