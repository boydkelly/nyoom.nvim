(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; (ab)using use-package! for lazy-loading
(use-package! :editor.scratch {:after editor.scratch
                               :cmd :Scratch})
