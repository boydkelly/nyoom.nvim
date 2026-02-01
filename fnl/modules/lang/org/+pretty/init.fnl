(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :lukas-reineke/headlines.nvim {:after lang.org.+pretty
                                             :ft :org
                                             :requires (pack :akinsho/org-bullets.nvim {:opt true})})
