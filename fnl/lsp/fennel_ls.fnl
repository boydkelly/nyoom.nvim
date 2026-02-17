{:capabilities {:offsetEncoding [:utf-8 :utf-16]}
 :cmd [:fennel-ls]
 :filetypes [:fennel]
 :root_markers [:flsproject.fnl :.jj :.git]
 :settings {:fennel 
            {:workspace {:library (vim.api.nvim_get_runtime_file "" true)
                         :checkThirdParty false}
             :diagnostics {:globals [:vim :include :view :unpack]}
             :macro-path ["fnl/?.fnl" "fnl/?/init.fnl"]
             :fennel-path ["fnl/?.fnl" "fnl/?/init.fnl"]}}
 :single_file_support true}
