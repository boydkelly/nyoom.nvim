(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :nvim-neo-tree/neo-tree.nvim
             {:nyoom-module ui.neotree
              :module :neo-tree
              :enabled true
              :cmd [:Neotree]
              :keys [[:<leader>op
                      "<cmd>Neotree toggle<CR>"
                      {:desc "Project sidebar"}]
                     [:<leader>oP
                      "<cmd>Neotree %:p:h:h %:p<CR>"
                      {:desc "Find file in project sidebar"}]]})
