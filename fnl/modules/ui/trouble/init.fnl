(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; view diagnostics ala vscode
(lz-package! :folke/trouble.nvim {:call-setup trouble :cmd :Trouble})
