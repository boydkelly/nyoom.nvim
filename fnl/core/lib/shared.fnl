(local userconfigs {})

(local databases-folder (.. (vim.fn.stdpath "data") "/databases"))

(local icons {:error ""
              :warn  ""
              :info  ""
              :hint  ""
              :ok    ""})

(local codicons {:Text "  "
                 :Method "  "
                 :Function "  "
                 :Constructor "  "
                 :Field "  "
                 :Variable "  "
                 :Class "  "
                 :Interface "  "
                 :Module "  "
                 :Property "  "
                 :Unit "  "
                 :Value "  "
                 :Enum "  "
                 :Keyword "  "
                 :Snippet "  "
                 :Color "  "
                 :File "  "
                 :Reference "  "
                 :Folder "  "
                 :EnumMember "  "
                 :Constant "  "
                 :Struct "  "
                 :Event "  "
                 :Operator "  "
                 :Copilot "  "
                 :TypeParameter "  "})

(local shared {: userconfigs
               : databases-folder
               : icons
               : codicons})

(tset _G :shared shared)

shared
