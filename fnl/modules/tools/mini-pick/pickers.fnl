(local M {})

(fn M.starter_custom []
  [{:action (fn []
              ((. (. (require :mini.extra) :pickers) :oldfiles)))
    :name "Recent Files"
    :section :Search}
   {:action :Project :name :Projects :section :Projects}
   {:action (fn []
              ((. (require :config.mini.pickers) :projects)))
    :name "Recent Projects"
    :section :Projects}])

(fn set-colorscheme [name]
  (pcall vim.cmd (.. "colorscheme " name)))

(set M.colorscheme (fn []
                     (let [init-scheme vim.g.colors_name
                           new-scheme ((. (require :mini.pick) :start) {:mappings {:preview {:char :<C-p>
                                                                                             :func (fn []
                                                                                                     (local item
                                                                                                            ((. (require :mini.pick)
                                                                                                                :get_picker_matches)))
                                                                                                     (pcall vim.cmd
                                                                                                            (.. "colorscheme "
                                                                                                                item.current)))}}
                                                                        :source {:choose set-colorscheme
                                                                                 :items (vim.fn.getcompletion ""
                                                                                                              :color)
                                                                                 :preview (fn [_
                                                                                               item]
                                                                                            (set-colorscheme item))}})]
                       (when (= new-scheme nil)
                         (set-colorscheme init-scheme)))))

(set M.nvimfiles
     (fn []
       (let [cwd (vim.fn.stdpath :config)
             handle (io.popen (.. "fd --max-depth 4 --type f --print0 --base-directory "
                                  cwd))]
         (when (not handle)
           (vim.notify "Failed to run fd command." vim.log.levels.ERROR)
           (lua "return "))
         (var file-paths {})
         (local output (handle:read :*a))
         (handle:close)
         (set file-paths (vim.split output "\000" {:plain true}))
         ((. (require :mini.pick) :start) {:source {:choose (fn [selected-path]
                                                              (vim.cmd (.. "edit "
                                                                           selected-path)))
                                                    : cwd
                                                    :items file-paths
                                                    :name "Neovim config files"}}))))

(set M.xgdfiles
     (fn []
       (let [cwd (.. vim.env.HOME :/.config)
             handle (io.popen (.. "fd --max-depth 4 --type f --print0 --base-directory "
                                  cwd))]
         (when (not handle)
           (vim.notify "Failed to run fd command." vim.log.levels.ERROR)
           (lua "return "))
         (local output (handle:read :*a))
         (handle:close)
         (var file-paths {})
         (set file-paths (vim.split output "\000" {:plain true}))
         ((. (require :mini.pick) :start) {:source {:choose (fn [selected-path]
                                                              (vim.cmd (.. "edit "
                                                                           selected-path)))
                                                    : cwd
                                                    :items file-paths
                                                    :name "XGD config files"}}))))

(fn abs [cwd path]
  (.. cwd "/" path))

(set M.readme
     (fn []
       (let [data-path (vim.fn.stdpath :data)]
         ((. (. (require :mini.pick) :builtin) :cli) {:command [:fd
                                                                :^README
                                                                :-i
                                                                :-H
                                                                :-I
                                                                :-t
                                                                :f]
                                                      :options {:cwd data-path}}
                                                     {:source {:choose (fn [item]
                                                                         (local full-path
                                                                                (vim.fs.normalize (.. data-path
                                                                                                      "/"
                                                                                                      item)))
                                                                         (vim.schedule (fn []
                                                                                         (vim.cmd (.. "edit "
                                                                                                      (vim.fn.fnameescape full-path))))))
                                                               :cwd data-path
                                                               :name "Plugin Readmes"}}))))

(set M.recent_icons
     (fn []
       (let [pick (require :mini.pick)
             micons (require :mini.icons)
             items (vim.tbl_filter vim.fn.filereadable vim.v.oldfiles)
             entries (vim.tbl_map (fn [path]
                                    (let [ft (or (vim.filetype.match {:filename path})
                                                 "")
                                          (icon icon-hl) (micons.get :filetype
                                                                     ft)]
                                      {:hl icon-hl
                                       :text (.. (or icon "") " " path)}))
                                  items)]
         (pick.start {:on_draw_item (fn [bufnr item idx]
                                      (when item.hl
                                        (vim.api.nvim_buf_add_highlight bufnr
                                                                        (- 1)
                                                                        item.hl
                                                                        (- idx
                                                                           1)
                                                                        0
                                                                        (length (item.text:match "^%S+")))))
                      :source {:choose (fn [item]
                                         (pick.choose_file item.path))
                               :items entries
                               :match (fn [item query]
                                        (pick.default_match item.text query))
                               :name "Recent files"
                               :preview (fn [item]
                                          (pick.preview_file item.path))}}))))

(set M.recent
     (fn []
       (let [pick (require :mini.pick)
             items (vim.tbl_filter (fn [f]
                                     (= (vim.fn.filereadable f) 1))
                                   vim.v.oldfiles)]
         (pick.start {:source {:choose pick.choose_file
                               : items
                               :match pick.default_match
                               :name "Recent files"
                               :preview pick.preview_file}}))))

(fn M.spellsuggest []
  (let [pick (require :mini.pick)
        original-win (vim.api.nvim_get_current_win)
        word (vim.fn.expand :<cword>)]
    (fn get-screen-pos []
      (let [(row col) (unpack (vim.api.nvim_win_get_cursor 0))
            pos (vim.fn.screenpos 0 row (+ col 1))]
        (values pos.row pos.col)))

    (local (screen-row screen-col) (get-screen-pos))
    (local total-lines vim.o.lines)
    (local height 6)
    (local fits-below (< (+ (+ screen-row height) 2) total-lines))
    (pick.start {:prompt "Correct spelling"
                 :source {:choose (fn [item]
                                    (vim.api.nvim_win_call original-win
                                                           (fn []
                                                             (local (row col)
                                                                    (unpack (vim.api.nvim_win_get_cursor 0)))
                                                             (local line
                                                                    (vim.api.nvim_get_current_line))
                                                             (local word
                                                                    (vim.fn.expand :<cword>))
                                                             (local (s e)
                                                                    (line:find (vim.pesc word)
                                                                               1
                                                                               true))
                                                             (when s
                                                               (vim.api.nvim_buf_set_text 0
                                                                                          (- row
                                                                                             1)
                                                                                          (- s
                                                                                             1)
                                                                                          (- row
                                                                                             1)
                                                                                          e
                                                                                          [item])))))
                          :items (vim.fn.spellsuggest word)
                          :name "Spelling suggestions"}
                 :window {:config (fn []
                                    {:anchor :NW
                                     :border :single
                                     :col (- screen-col 1)
                                     : height
                                     :row (or (and fits-below screen-row)
                                              (- (- screen-row height) 1))
                                     :width (math.floor (* vim.o.columns 0.28))})}})))

(fn M.unicode_characters []
  (let [unicode-csv (.. (vim.fn.stdpath :data) :/site/unicode/UnicodeRef.csv)
        unicode-data {}]
    (each [line (io.lines unicode-csv)]
      (local (code char desc) (line:match "([^,]+),([^,]+),(.+)"))
      (when (and (and code char) desc)
        (table.insert unicode-data
                      {: char
                       : code
                       : desc
                       :id code
                       :text (.. code " " char " " desc)})))
    (local bufnr (vim.api.nvim_get_current_buf))
    (local (row col) (unpack (vim.api.nvim_win_get_cursor 0)))
    ((. (require :mini.pick) :start) {:backend :fzf
                                      :source {:choose (fn [selection]
                                                         (vim.notify (vim.inspect selection))
                                                         (when (and selection
                                                                    selection.char)
                                                           (vim.api.nvim_buf_set_text bufnr
                                                                                      (- row
                                                                                         1)
                                                                                      col
                                                                                      (- row
                                                                                         1)
                                                                                      col
                                                                                      [selection.char])))
                                               :items unicode-data
                                               :name "Unicode characters"
                                               :search (fn [item query]
                                                         (set-forcibly! query
                                                                        (: (or query
                                                                               "")
                                                                           :lower))
                                                         (or (or (: (item.char:lower)
                                                                    :find query
                                                                    1 true)
                                                                 (: (item.code:lower)
                                                                    :find query
                                                                    1 true))
                                                             (: (item.desc:lower)
                                                                :find query 1
                                                                true)))}
                                      :window {:config nil
                                               :prompt_caret "▏"
                                               :prompt_prefix "> "}})))

(fn win-config []
  (let [height (math.floor (* 0.618 vim.o.lines))
        width (math.floor (* 0.6 vim.o.columns))]
    {:anchor :NW
     :border :none
     :col (math.floor (* 0.5 (- vim.o.columns width)))
     : height
     :row (math.floor (* 0.5 (- vim.o.lines height)))
     : width}))

(fn M.projects []
  (var recent-projects ((. (require :project) :get_recent_projects)))

  (fn format-for-display [project-path]
    (let [name (or (project-path:match "/([^/]+)$") project-path)]
      (values name (string.format "%-30s %s" name project-path))))

  (set recent-projects (vim.tbl_reverse recent-projects))
  (local projects-display {})
  (local projects-data {})
  (each [_ project-path (ipairs recent-projects)]
    (local (name display) (format-for-display project-path))
    (table.insert projects-display display)
    (tset projects-data display {: name :path project-path}))
  ((. (require :mini.pick) :start) {:mappings {:set_root_on_esc {:char :<Esc>
                                                                 :func (fn []
                                                                         (local Mini-pick
                                                                                (require :mini.pick))
                                                                         (local st
                                                                                (Mini-pick.get_picker_state))
                                                                         (when (and (and (and st
                                                                                              st.items)
                                                                                         st.items.all)
                                                                                    st.caret)
                                                                           (local selection
                                                                                  (. st.items.all
                                                                                     st.caret))
                                                                           (local data
                                                                                  (. projects-data
                                                                                     selection))
                                                                           (when (and data
                                                                                      data.path)
                                                                             (vim.schedule (fn []
                                                                                             (vim.cmd (.. "ProjectRoot "
                                                                                                          (vim.fn.fnameescape data.path)))
                                                                                             (vim.notify (.. "Root set to: "
                                                                                                             data.path))))))
                                                                         (Mini-pick.stop))}}
                                    :source {:choose (fn [selection]
                                                       (local data
                                                              (. projects-data
                                                                 selection))
                                                       (when (or (not data)
                                                                 (not data.path))
                                                         (lua "return "))
                                                       (local target-cwd
                                                              data.path)
                                                       (vim.schedule (fn []
                                                                       (vim.fn.chdir target-cwd)
                                                                       ((. (. (require :mini.pick)
                                                                              :builtin)
                                                                           :files) nil
                                                                                                                                                                                                                                                                              {:source {:cwd target-cwd
                                                                                                                                                                                                                                                                                        :name (.. "Files in "
                                                                                                                                                                                                                                                                                                  data.name)}}))))
                                             :items projects-display
                                             :name :Projects}}))

M
