(import-macros {: use-package!} :macros)

; show hex codes as virtualtext
(use-package! :uga-rosa/ccc.nvim {:after tools.rgb
                                  :cmd [:CccPick
                                        :CccHighlighterEnable
                                        :CccHighlighterToggle]})
