(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :rafikdraoui/jj-diffconflicts
             {:nyoom-module tools.jj.+diffview :cmd [:JJDiffConflicts]})
