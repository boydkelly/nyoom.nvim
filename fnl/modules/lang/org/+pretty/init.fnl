(import-macros {: lz-package! : vim-pack-spec! : lz-trigger-load!} :macros)

(lz-package! :lukas-reineke/headlines.nvim {:nyoom-module lang.org.+pretty
                                             :ft :org
                                             :requires [(lz-trigger-load! :akinsho/org-bullets.nvim)]})
