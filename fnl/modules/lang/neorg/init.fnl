(import-macros {: lz-package! : build-pack-table : build-before-all-hook } :macros)

(lz-package! :nvim-neorg/neorg
  {:nyoom-module lang.neorg
   :ft :norg
   :requires [:nvim-neorg/lua-utils.nvim
              :pysan3/pathlib.nvim
              :nvim-neotest/nvim-nio]})
