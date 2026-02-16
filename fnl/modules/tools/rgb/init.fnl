(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

; show hex codes as virtualtext
(lz-package! :uga-rosa/ccc.nvim {:nyoom-module tools.rgb
                                  :cmd [:CccPick
                                        :CccHighlighterEnable
                                        :CccHighlighterToggle]})
