(import-macros {: use-package!} :macros)

(lz-package! :nvim-tree/nvim-web-devicons
              {:module :nvim-web-devicons
               :after ui.nyoom.+icons
               :requires [(lz-pack :DaikyXendo/nvim-material-icon {:opt true})]})
