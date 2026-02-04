(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

(lz-package! :nvim-neorg/neorg
  {:nyoom-module lang.neorg
   :ft :norg
   :requires [(lz-pack! :nvim-neorg/lua-utils.nvim {:opt true})
              (lz-pack! :pysan3/pathlib.nvim   {:opt true})
              (lz-pack! :nvim-neotest/nvim-nio      {:opt true})]})
