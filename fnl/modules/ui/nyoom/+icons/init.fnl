(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

(lz-package! :nvim-tree/nvim-web-devicons
              {:module :nvim-web-devicons
               :nyoom-module ui.nyoom.+icons
               :requires [(lz-pack! :DaikyXendo/nvim-material-icon {:opt true})]})
