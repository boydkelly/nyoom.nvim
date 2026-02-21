(import-macros {: lz-package! : build-pack-table : build-before-all-hook } :macros)

(lz-package! :lukas-reineke/headlines.nvim {:nyoom-module lang.org.+pretty
                                             :ft :org
                                             :requires [:akinsho/org-bullets.nvim]})
