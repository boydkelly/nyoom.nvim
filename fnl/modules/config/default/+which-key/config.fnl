(local {: setup} (require :core.lib.setup))
(import-macros {: nyoom-module-p!} :macros)

(local spelling (nyoom-module-p! spell))

(local opts {;; 1. New Icon System
             :icons {:breadcrumb "»" :group "+" :rules false}
             :win {:border :solid :padding [0 0]}
             :layout {:spacing 4 :align :center}
             :filter (fn [mapping]
                       (let [mode mapping.mode
                             key mapping.lhs]
                         (not (and (or (= mode :i) (= mode :v))
                                   (or (= key :j) (= key :k))))))
             :plugins {:presets {:g true :windows true :z true}
                       ;; Use the variable here
                       :spelling {:enabled false}}
             :replace {:desc [[:<silent> ""]
                              [:<cmd> ""]
                              [:<Cmd> ""]
                              [:<CR> ""]
                              [:call ""]
                              [:lua ""]
                              ["^:" ""]
                              ["^ " ""]]}})

(setup :which-key opts)

;; rename groups to mimick doom
(local wk (require :which-key))

(wk.add [{1 :<leader><tab> :group :workspace}
         {1 :<leader>b :group :buffer}
         {1 :<leader>c :group :code}
         {1 :<leader>cl :group :LSP}
         {1 :<leader>f :group :file}
         {1 :<leader>g :group :git}
         {1 :<leader>h :group :help}
         {1 :<leader>hn :group :nyoom}
         {1 :<leader>i :group :insert}
         {1 :<leader>j :group :jj}
         {1 :<leader>n :group :notes}
         {1 :<leader>o :group :open}
         {1 :<leader>oa :group :agenda}
         {1 :<leader>ot :group :terminal}
         ; {1 :<leader>p :group :project}
         {1 :<leader>q :group :quit/session}
         {1 :<leader>r :group :remote}
         {1 :<leader>s :group :search}
         {1 :<leader>t :group :toggle}
         {1 :<leader>w :group :window}
         {1 :<leader>m :group :localleader}
         {1 :<leader>d :group :debug}
         {1 :<leader>v :group :visual}])

(include :modules.config.default.+which-key.custom)

