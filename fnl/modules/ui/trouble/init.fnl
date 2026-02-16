(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

;; view diagnostics ala vscode
(lz-package! :folke/trouble.nvim {:call-setup trouble :cmd :Trouble})
