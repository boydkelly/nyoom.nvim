(local userconfigs {})

(local databases-folder (.. (vim.fn.stdpath "data") "/databases"))

(local icons {:error " "
              :warn  " "
              :info  " "
              :hint  " "
              :ok    " "})

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

;; ... (rest of the file remains the same)

(local shared-table {: userconfigs
                     : databases-folder
                     : icons
                     : codicons})

;; 1. Set the global for legacy code
(tset _G :shared shared-table)

;; 2. Return the table for the bootstrap function
shared-table
