(import-macros {: lz-package! : vim-pack-spec! : lz-trigger-load!} :macros)

(lz-package! :rcarriga/nvim-dap
              {:nyoom-module tools.debugger
               :opt true
               :defer nvim-dap
               :requires [(lz-trigger-load! :rcarriga/nvim-dap-ui {:opt true})
                          (lz-trigger-load! :mfussenegger/nvim-dap-python {:opt true})
                          (lz-trigger-load! :jbyuki/one-small-step-for-vimkind {:opt true})]})
