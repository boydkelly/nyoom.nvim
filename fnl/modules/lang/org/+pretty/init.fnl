(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

(lz-package! :lukas-reineke/headlines.nvim {:nyoom-module lang.org.+pretty
                                             :ft :org
                                             :requires [(lz-pack! :akinsho/org-bullets.nvim)]})
