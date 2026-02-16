(import-macros {: map!} :macros)
(local {: setup} (require :core.lib.setup))

;; JJ Keybindings (Manual Migration from lz.n keys)

(map! [n] :<leader>jD #((. (require :jj.cmd) :describe)) {:desc "JJ describe"})
(map! [n] :<leader>jl #((. (require :jj.cmd) :log)) {:desc "JJ log"})
(map! [n] :<leader>jc #((. (require :jj.cmd) :commit)) {:desc "JJ commit"})
(map! [n] :<leader>je #((. (require :jj.cmd) :edit)) {:desc "JJ edit"})
(map! [n] :<leader>jn #((. (require :jj.cmd) :new)) {:desc "JJ new"})
(map! [n] :<leader>js #((. (require :jj.cmd) :status)) {:desc "JJ status"})
(map! [n] :<leader>jq #((. (require :jj.cmd) :squash)) {:desc "JJ squash"})
(map! [n] :<leader>ju #((. (require :jj.cmd) :undo)) {:desc "JJ undo"})
(map! [n] :<leader>jy #((. (require :jj.cmd) :redo)) {:desc "JJ redo"})
(map! [n] :<leader>jr #((. (require :jj.cmd) :rebase)) {:desc "JJ rebase"})
(map! [n] :<leader>jb #((. (require :jj.cmd) :bookmark_create))
      {:desc "JJ bookmark create"})

(map! [n] :<leader>jB #((. (require :jj.cmd) :bookmark_delete))
      {:desc "JJ bookmark delete"})

(map! [n] :<leader>jd #((. (require :jj.diff) :open_vdiff))
      {:desc "JJ diff current buffer"})

;; Complex calls
(map! [n] :<leader>jL
      (fn []
        (((. (require :jj.cmd) :log)) {:revisions "'all()'"}))
      {:desc "JJ log all"})

(map! [n] :<leader>jt
      (fn []
        (((. (require :jj.cmd) :j) "tug cmd.log") {})) {:desc "JJ tug"})

(setup :jj {:describe_editor :input})

