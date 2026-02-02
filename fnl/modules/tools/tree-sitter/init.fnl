(import-macros {: lz-package! : vim-pack-spec! : lz-pack! : pack} :macros)

(lz-package! :nvim-treesitter/nvim-treesitter
              {:after tools.tree-sitter
               :cmd [:TSInstall
                     :TSEnable
                     :TSDisable]
               :requires [
                          ; (lz-pack! :HiPhish/nvim-ts-rainbow2 {:opt true})
                          (lz-pack! :JoosepAlviste/nvim-ts-context-commentstring {:opt true})
                          (lz-pack! :nvim-treesitter/nvim-treesitter-textobjects
                                {:opt true})]
               :setup (fn []
                        (vim.api.nvim_create_autocmd [:BufRead]
                                                     {:group (vim.api.nvim_create_augroup :nvim-treesitter
                                                                                          {})
                                                      :callback (fn []
                                                                  (when (fn []
                                                                          (local file
                                                                                 (vim.fn.expand "%"))
                                                                          (and (and (not= file
                                                                                          :NvimTree_1)
                                                                                    (not= file
                                                                                          "[packer]"))
                                                                               (not= file
                                                                                     "")))
                                                                    (vim.api.nvim_del_augroup_by_name :nvim-treesitter)
                                                                    ((. (_G.autoload :packer)
                                                                        :loader) :nvim-treesitter)))}))})
