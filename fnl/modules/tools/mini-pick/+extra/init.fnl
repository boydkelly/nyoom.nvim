(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :nvim-mini/mini.extra
             {:nyoom-module tools.mini-pick.+extra
              :cmd :Pick
              :event :UIEnter
              :require [[:mini.pick] :packadd]
              :keys [{1 "<leader>a:"
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :commands)))
          :desc "run command"}
         {1 "<leader>a;"
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :history)))
          :desc "run from command history"}
         {1 :<leader>ao
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :options)))
          :desc "set nvim option"}
         {1 :<leader>nm
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :marks)))
          :desc :marks}
         {1 :<leader>fr
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :oldfiles)))
          :desc "recent files"}
         {1 :<leader>fx
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :explorer)))
          :desc :explorer}
         {1 :<leader>hm
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :manpages)))
          :desc "man pages"}
         {1 :<leader>sK
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :keymaps)))
          :desc :keymaps}
         {1 :<leader>sr
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :registers)))
          :desc :registers}
         {1 :<leader>eh
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :hl_groups)))
          :desc "find hl groups"}
         {1 :<leader>sb
          2 (fn []
              ((. (. (require :mini.extra) :pickers) :buf_lines) {:scope :current}))
          :desc "search lines"
          :nowait true}]
  })
