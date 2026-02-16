(import-macros {: lz-package! : build-pack-table : build-before-all-hook } :macros)

(lz-package! :nvim-neorg/neorg
  {:nyoom-module lang.neorg
   :ft :norg
   :requires [(lz-trigger-load! :nvim-neorg/lua-utils.nvim {:opt true})
              (lz-trigger-load! :pysan3/pathlib.nvim   {:opt true})
              (lz-trigger-load! :nvim-neotest/nvim-nio      {:opt true})]})
