(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

; view diagnostics ala vscode
(lz-pack! :yorickpeterse/nvim-pqf {:call-setup nvim-pqf :ft :qf})
