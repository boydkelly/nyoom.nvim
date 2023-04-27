(import-macros {: use-package!} :macros)

(use-package! :cuducos/yaml.nvim
              {:nyoom-module lang.yaml
                :ft :yaml
                :requires [(pack :nvim-tresitter/nvim-treesitter)
                           (pack :nvim-telescope.nvim)]})
