(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :ellisonleao/glow.nvim {:cmd :Glow
	                              :call-setup glow})
