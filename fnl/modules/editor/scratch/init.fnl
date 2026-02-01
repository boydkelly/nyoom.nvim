(import-macros {: use-package!} :macros)

;; (ab)using use-package! for lazy-loading
(use-package! :editor.scratch {:after editor.scratch
                               :cmd :Scratch})
