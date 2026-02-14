(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :stevearc/oil.nvim {:nyoom-module ui.oil :cmd :Oil :module :oil})

; (lz-package! :stevearc/oil.nvim
;              {:nyoom-module ui.oil
;               :enabled true
;               :module :oil
;               :keys [{1 "-"
;                       2 (fn []
;                           (_G.toggle_oil_split))
;                       :desc "Toggle Oil"}
;                      {1 :<leader>fe
;                       2 (fn []
;                           (_G.toggle_oil_split))
;                       :desc "Toggle Oil"}]})
;
