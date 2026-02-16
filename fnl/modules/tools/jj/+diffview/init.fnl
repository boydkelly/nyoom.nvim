(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :rafikdraoui/jj-diffconflicts
             {:nyoom-module tools.jj.+diffview :cmd [:JJDiffConflicts]})
