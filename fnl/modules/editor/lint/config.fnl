(import-macros {: nyoom-module-p! : augroup! : autocmd! : command!} :macros)

(local lint (require :lint))
(local active-linters {})

(tset lint.linters_by_ft :query nil)

(fn register-linter [ft names]
  (tset active-linters ft names))

(nyoom-module-p! python (register-linter :python [:pylint]))
(nyoom-module-p! json (register-linter :json [:jsonlint]))
(nyoom-module-p! markdown (register-linter :markdown [:markdownlint]))
(nyoom-module-p! javascript
                (do (register-linter :javascript [:eslint])
                    (register-linter :typescript [:eslint])))

(set lint.linters_by_ft active-linters)

(augroup! nvim-lint-configs
  (autocmd! [:BufEnter :BufWritePost :InsertLeave] "*"
            (fn [] (lint.try_lint))
            {:desc "Trigger nvim-lint diagnostics"}))

(command! LintInfo
          (fn []
            (let [lint (require :lint)
                  ft vim.bo.filetype
                  linters (. lint.linters_by_ft ft)]
              (if (and linters (> (length linters) 0))
                  (vim.notify (.. "Linters for " ft ": " (table.concat linters ", "))
                              vim.log.levels.INFO)
                  (vim.notify (.. "No linters configured for " ft)
                              vim.log.levels.WARN))))
          {:desc "Show active linters for the current buffer"})
