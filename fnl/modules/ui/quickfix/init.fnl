(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; view diagnostics ala vscode
(use-package! :yorickpeterse/nvim-pqf {:call-setup nvim-pqf :cmd [:copen :cclose]})
