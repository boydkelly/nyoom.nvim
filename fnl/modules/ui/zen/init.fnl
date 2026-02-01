(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :Pocco81/true-zen.nvim
              {:call-setup true-zen
               :cmd [:TZAtaraxis :TZNarrow :TZFocus :TZMinimalist :TZAtaraxis]})
