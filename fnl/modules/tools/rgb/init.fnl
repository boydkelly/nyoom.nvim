(import-macros {: lz-package! : vim-pack-spec!} :macros)

; show hex codes as virtualtext
(use-package! :uga-rosa/ccc.nvim {:after tools.rgb
                                  :cmd [:CccPick
                                        :CccHighlighterEnable
                                        :CccHighlighterToggle]})
