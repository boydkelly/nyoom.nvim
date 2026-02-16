(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :rktjmp/paperplanes.nvim {:after tools.pastebin
                                        :cmd :PP})
