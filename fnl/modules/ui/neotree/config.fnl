(local {: setup} (require :core.lib.setup))
(import-macros {: let! : packadd!} :macros)
(print "nvim-tree setup")
(packadd! :nui.nvim)
(packadd! :plenary.nvim)
; (let! neo_tree_remove_legacy_commands 1)
(setup :neotree)
; (setup :neo-tree
;        {:use_popups_for_input true
;         :popup_border_style :solid
;         :window {:position :left :width 25}
;         :filesystem {:use_libuv_file_watcher true}
;         :default_component_configs {:indent {:with_markers false}
;                                     :git_status {:symbols {:deleted ""
;                                                            :renamed "凜"
;                                                            :untracked ""
;                                                            :ignored ""
;                                                            :unstaged ""
;                                                            :staged ""
;                                                            :conflict ""}}}})
;

