(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; view diagnostics ala vscode
(lz-package! :yorickpeterse/nvim-pqf {:call-setup nvim-pqf :ft :qf})
