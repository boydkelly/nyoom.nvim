(import-macros {: lz-pack! : vim-pack-spec!} :macros)

;; view diagnostics ala vscode
(lz-pack! :yorickpeterse/nvim-pqf {:call-setup pqf :ft :qf})
