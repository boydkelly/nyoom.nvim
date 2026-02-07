(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :nvim-neo-tree/neo-tree.nvim
             {:nyoom-module ui.neotree
              :module :neo-tree
              :keys [[:<leader>op
                      "<cmd>Neotree toggle<CR>"
                      {:desc "Project sidebar"}]
                     [:<leader>oP
                      "<cmd>Neotree %:p:h:h %:p<CR>"
                      {:desc "Find file in project sidebar"}]]})
