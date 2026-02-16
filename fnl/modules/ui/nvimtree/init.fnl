(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :kyazdani42/nvim-tree.lua
             {:nyoom-module ui.nvimtree
              :module :nvim-tree
              :event :UIEnter
              :cmd :NvimTreeToggle
              :keys [[:<leader>op
                      :<cmd>NvimTreeToggle<CR>
                      {:desc "Project sidebar"}]
                     [:<leader>oP
                      :<cmd>NvimTreeFindFile<CR>
                      {:desc "Find file in project sidebar"}]]})
