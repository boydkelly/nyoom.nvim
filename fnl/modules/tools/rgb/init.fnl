(import-macros {: lz-package! : vim-pack-spec!} :macros)

; show hex codes as virtualtext
(lz-package! :uga-rosa/ccc.nvim {:nyoom-module tools.rgb
                                  :cmd [:CccPick
                                        :CccHighlighterEnable
                                        :CccHighlighterToggle]})
