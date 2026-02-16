(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

; Magit for neovim
(lz-package! :nicolasgb/jj.nvim
             {:nyoom-module tools.jj
              :keys [{1 :<leader>jD
                      2 (fn []
                          ((. (require :jj.cmd) :describe)))
                      :desc "JJ describe"}
                     {1 :<leader>jl
                      2 (fn []
                          ((. (require :jj.cmd) :log)))
                      :desc "JJ log"}
                     {1 :<leader>jc
                      2 (fn []
                          ((. (require :jj.cmd) :commit)))
                      :desc "JJ commit"}
                     {1 :<leader>je
                      2 (fn []
                          ((. (require :jj.cmd) :edit)))
                      :desc "JJ edit"}
                     {1 :<leader>jn
                      2 (fn []
                          ((. (require :jj.cmd) :new)))
                      :desc "JJ new"}
                     {1 :<leader>js
                      2 (fn []
                          ((. (require :jj.cmd) :status)))
                      :desc "JJ status"}
                     {1 :<leader>jq
                      2 (fn []
                          ((. (require :jj.cmd) :squash)))
                      :desc "JJ squash"}
                     {1 :<leader>ju
                      2 (fn []
                          ((. (require :jj.cmd) :undo)))
                      :desc "JJ undo"}
                     {1 :<leader>jy
                      2 (fn []
                          ((. (require :jj.cmd) :redo)))
                      :desc "JJ redo"}
                     {1 :<leader>jr
                      2 (fn []
                          ((. (require :jj.cmd) :rebase)))
                      :desc "JJ rebase"}
                     {1 :<leader>jb
                      2 (fn []
                          ((. (require :jj.cmd) :bookmark_create)))
                      :desc "JJ bookmark create"}
                     {1 :<leader>jB
                      2 (fn []
                          ((. (require :jj.cmd) :bookmark_delete)))
                      :desc "JJ bookmark delete"}
                     {1 :<leader>jL
                      2 (fn []
                          (((. (require :jj.cmd) :log)) {:revisions "'all()'"}))
                      :desc "JJ log all"}
                     {1 :<leader>jt
                      2 (fn []
                          (((. (require :jj.cmd) :j) "tug cmd.log") {}))
                      :desc "JJ tug"}
                     {1 :<leader>jd
                      2 (fn []
                          ((. (require :jj.diff) :open_vdiff)))
                      :desc "JJ diff current buffer"}]})

