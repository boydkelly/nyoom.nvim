{:capabilities {:offsetEncoding [:utf-8 :utf-16]}
 :cmd [:fennel-ls]
 :filetypes [:fennel]
 :root_markers [:.jj :.git]
 :settings {:fennel
            {:diagnostics {:globals [:vim :include :view :unpack]}
             :macro-path ["./?.fnl" "fnl/?.fnl" "fnl/?/init.fnl"]
             :fennel-path ["fnl/?.fnl" "fnl/?/init.fnl"]
             :lua-version "lua5.1"
             :libraries {:nvim true}
             :extra-globals "vim unpack include view"}
 ; :fennel-path ["./fnl/?.fnl" "./fnl/?/init.fnl"]
 ; :macro-path  ["./fnl/?.fnl" "./fnl/?/init.fnl"]
}
:single_file_support true}
