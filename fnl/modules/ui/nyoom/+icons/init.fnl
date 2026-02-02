(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

(lz-package! :DaikyXendo/nvim-material-icon)
              ; {:packadd! :nvim-material-icon})

(lz-package! :nvim-tree/nvim-web-devicons
              {:module :nvim-web-devicons
               :nyoom-module ui.nyoom.+icons})
