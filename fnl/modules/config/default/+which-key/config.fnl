(local {: setup} (require :core.lib.setup))

(local opts {:icons {:rules false}
             :plugins {:presets {:g true :windows true :z true}
                       :spelling {:enabled false}}
             :win {:padding [1 0]}})

(setup :which-key opts)

; (setup :which-key {:icons {:breadcrumb "»" :separator "->" :group "+"}
;                    :popup_mappings {:scroll_down :<c-d> :scroll_up :<c-u>}
;                    :window {:border :solid}
;                    :layout {:spacing 3}
;                    :hidden [:<silent> :<cmd> :<Cmd> :<CR> :call :lua "^:" "^ "]
;                    :triggers_blacklist {:i [:j :k] :v [:j :k]}
;                    :height {:min 0 :max 6}
;                    :align :center})
;
;; rename groups to mimick doom
(local wk (require :which-key))

(wk.add [
         {1 :<leader><tab> :group :workspace}
         {1 :<leader>b :group :buffer}
         {1 :<leader>c :group :code}
         {1 :<leader>cl :group :LSP}
         {1 :<leader>f :group :file}
         {1 :<leader>g :group :git}
         {1 :<leader>h :group :help}
         {1 :<leader>hn :group :nyoom}
         {1 :<leader>i :group :insert}
         {1 :<leader>n :group :notes}
         {1 :<leader>o :group :open}
         {1 :<leader>oa :group :agenda}
         {1 :<leader>p :group :project}
         {1 :<leader>q :group :quit/session}
         {1 :<leader>r :group :remote}
         {1 :<leader>s :group :search}
         {1 :<leader>t :group :toggle}
         {1 :<leader>w :group :window}
         {1 :<leader>m :group :localleader}
         {1 :<leader>d :group :debug}
         {1 :<leader>v :group :visual}])
