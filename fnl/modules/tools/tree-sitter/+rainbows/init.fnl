(import-macros {: lz-package! : vim-pack-spec! : lz-pack! : pack} :macros)

(lz-package! :https://github.com/HiPhish/rainbow-delimiters.nvim
              {:call-setup rainbow-delimiters.setup})
