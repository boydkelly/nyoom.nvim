(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

; view diagnostics ala vscode
(lz-package! :yorickpeterse/nvim-pqf {:call-setup nvim-pqf :ft :qf})
