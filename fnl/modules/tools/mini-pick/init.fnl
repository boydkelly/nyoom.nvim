(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)
; (include :modules.tools.mini-pick.pickers)
; (local pickers (require :modules.tools.mini-pick.pickers))

(lz-package! :nvim-mini/mini.pick
             {:nyoom-module tools.mini-pick
              :cmd :Pick
              :requires [:https://github.com/nvim-mini/mini.extra]
              :event :UIEnter
              :enabled true
              :keys [{1 "<leader> "
          2 (fn []
              ((. (. (require :mini.pick) :builtin) :files)))
          :desc :Files}
         {1 :<leader>bt
          2 (fn []
              ((. (. (require :mini.pick) :builtin) :buffers)))
          :desc "List buffers"}
         {1 :<leader>hh
          2 (fn []
              ((. (. (require :mini.pick) :builtin) :help)))
          :desc :Help}
         {1 :<leader>sr
          2 (fn []
              ((. (. (require :mini.pick) :builtin) :resume)))
          :desc "Resume last search"}
         {1 :<leader>sk
          2 (fn []
              (local wrd (vim.fn.expand :<cword>))
              ((. (. (require :mini.pick) :builtin) :grep) {:pattern wrd}))
          :desc "Word under cursor"}
         {1 :<leader>hr 2 pickers.readme :desc "Plugin readme files"}
         {1 :<leader>ec 2 pickers.colorscheme :desc "Change colorscheme"}
         {1 :<leader>su 2 pickers.unicode_characters :desc "Search unicode"}
         {1 :z= 2 pickers.spellsuggest :desc ""}]
             })
