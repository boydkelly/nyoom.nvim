(import-macros {: lz-package! : vim-pack-spec! : autocmd!} :macros)

(use-package! :lewis6991/gitsigns.nvim
              {:after ui.vc-gutter
               :ft :gitcommit
               :module :gitsigns
               :setup (fn []
                        (autocmd! BufRead *
                                  `(fn []
                                     (vim.fn.system (.. "git -C "
                                                        (vim.fn.expand "%:p:h")
                                                        " rev-parse"))
                                     (when (= vim.v.shell_error 0)
                                       (vim.schedule (fn []
                                                       ((. (require :packer)
                                                           :loader) :gitsigns.nvim)))))))})
