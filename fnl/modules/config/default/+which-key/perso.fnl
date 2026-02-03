(local {: setup} (require :core.lib.setup))
(local opts {:icons {:rules false}
             :plugins {:presets {:g true :windows true :z true}
                       :spelling {:enabled false}}
             :win {:padding [1 0]}})

(setup :which-key opts)

(local wk (require :which-key))

(wk.add [{1 {1 :<leader>a :group :Admin}
          2 {1 :<leader>ap :group :Plugins}
          3 {1 :<leader>ak :group :Keyboard}
          4 {1 :<leader>b :group :Buffers}
          5 {1 :<leader>c :group :Code}
          6 {1 :<leader>cf :group :Format}
          7 {1 :<leader>ct :group "Toggle code options"}
          8 {1 :<leader>e :group :Editor}
          9 {1 :<leader>et :group "Toggle options"}
          10 {1 :<leader>f :group :File}
          11 {1 :<leader>h :group :Help}
          12 {1 :<leader>i :group :Input}
          13 {1 :<leader>ik :group :Keymaps}
          14 {1 :<leader>j :group :Jujutsu}
          15 {1 :<leader>m :group :Markup}
          16 {1 :<leader>n :group :Navigation}
          17 {1 :<leader>mc :group :Convert}
          18 {1 :<leader>mo :group :Open}
          19 {1 :<leader>s :group :Search}
          20 {1 :<leader>sm :group :Mandenkan}
          21 {1 :<leader>S :group :Session}
          22 {1 :<leader>t :group :Terminal}
          23 {1 :<localleader>k :group :Keyboard}
          24 {1 :<localleader>u :group :Ui}
          25 {1 :<C-w>n :group "New split scratch buffer"}
          :mode [:n]}
         {1 {1 :<leader>m :group "dyu dictionnaire"}
          2 [:<leader>ma
             ":w >> ./remove/abbrev.txt<cr>|gvd"
             {:desc :Abbreviations :silent true}]
          3 [:<leader>mb
             ":w >> ./remove/bible-names.txt<cr>|gvd"
             {:desc "Bible Names" :silent true}]
          4 [:<leader>mf
             ":w >> ./remove/geo-foreign.txt<cr>|gvd"
             {:desc "Geo Foreign" :silent true}]
          5 [:<leader>mg
             ":w >> ./remove/geo.txt<cr>|gvd"
             {:desc "Geo Dyula" :silent true}]
          6 [:<leader>mn
             ":w >> ./addwords.txt<cr>|gvd"
             {:desc "Add Words" :silent true}]
          7 [:<leader>mp
             ":w >> ./remove/proper-names.txt<cr>|gvd"
             {:desc "Proper Names" :silent true}]
          8 [:<leader>mr
             ":w >> ./remove/remove.txt<cr>|gvd"
             {:desc "Remove it!" :silent true}]
          9 [:<leader>mt
             ":w >> ./remove/typos.txt<cr>|gvd"
             {:desc :Typos :silent true}]
          10 [:<leader>mu
              ":w >> ./remove/unclassified.txt<cr>|gvd"
              {:desc :Geo :silent true}]
          :mode [:v]}])
