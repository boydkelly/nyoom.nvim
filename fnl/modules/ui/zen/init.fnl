(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :Pocco81/true-zen.nvim
             {:call-setup true-zen
              :cmd [:TZAtaraxis :TZNarrow :TZFocus :TZMinimalist :TZAtaraxis]})

