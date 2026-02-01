(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :rktjmp/paperplanes.nvim {:after tools.pastebin
                                        :cmd :PP})
