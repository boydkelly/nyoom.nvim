(import-macros {: set! : nyoom-module-p! : map!} :macros)

;; --- 1. Define Option Tables ---

(local bash-options {:shell :sh
                     :shellcmdflag :-c
                     :shellpipe "2>&1 | tee"
                     :shellquote ""
                     :shellredir ">%s 2>&1"
                     :shelltemp true
                     :shellxescape ""
                     :shellxquote ""})

(local fish-options {:shell :fish
                     :shellpipe "|"
                     :shellredir ">%s 2>&1"})

(local nu-options {:shell :nu
                   :shellcmdflag "--login --stdin --no-newline -c"
                   :shellpipe "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
                   :shellquote ""
                   :shellredir "out+err> %s"
                   :shelltemp false
                   :shellxescape ""
                   :shellxquote ""})

;; --- 2. Helper Functions ---

(fn set-shell-options [opts]
  (each [k v (pairs opts)]
    (tset vim.opt k v)))

;; --- 3. Logic Application ---

;; Always apply Bash as the safe default for system calls/plugins
(set-shell-options bash-options)

;; Shortcut for the default terminal
(map! [n] :<leader>otv ":vnew +terminal | startinsert<CR>" {:desc "Terminal (sh)"})

;; Logic for Fish
(nyoom-module-p! sh.+fish
  (do
    (set-shell-options fish-options)
    ;; Fish usually doesn't need to be the global 'vim.opt.shell'
    ;; to avoid breaking POSIX plugins, but we provide the shortcut:
    (map! [n] :<leader>otf ":vnew term://fish | startinsert<CR>" {:desc "Terminal (fish)"})))

;; Logic for Nushell
(nyoom-module-p! sh.+nu
  (do
    ;; Nushell is picky, so if the user wants it, we apply the full option set
    (set-shell-options nu-options)
    (map! [n] :<leader>otn ":vnew term://nu | startinsert<CR>" {:desc "Terminal (nu)"})))
