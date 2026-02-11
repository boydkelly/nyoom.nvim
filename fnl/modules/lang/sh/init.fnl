(import-macros {: set! : nyoom-module-p! : map!} :macros)

;; --- 1. Define Option Tables ---

; (local bash-options {:shell :sh
;                      :shellcmdflag :-c
;                      :shellpipe "2>&1 | tee"
;                      :shellquote ""
;                      :shellredir ">%s 2>&1"
;                      :shelltemp true
;                      :shellxescape ""
;                      :shellxquote ""})
;
(local fish-options {:shell :fish :shellpipe "|" :shellredir ">%s 2>&1"})

(local nu-options {:shell :nu
                   :shellcmdflag "--login --stdin --no-newline -c"
                   :shellpipe "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
                   :shellquote ""
                   :shellredir "out+err> %s"
                   :shelltemp false
                   :shellxescape ""
                   :shellxquote ""})

(fn set-shell-options [opts]
  (each [k v (pairs opts)]
    (tset vim.opt k v)))

; (set-shell-options bash-options)

(map! [n] :<leader>otv ":vnew +terminal | startinsert<CR>"
      {:desc "Terminal (sh)"})

(nyoom-module-p! sh.+fish
                 (do
                   (set-shell-options fish-options)
                   (map! [n] :<leader>otf ":vnew term://fish | startinsert<CR>"
                         {:desc "Open terminal (fish)"})))

(nyoom-module-p! sh.+nu
                 (do
                   (set-shell-options nu-options)
                   (map! [n] :<leader>otn ":vnew term://nu | startinsert<CR>"
                         {:desc "Open terminal (nu)"})))

