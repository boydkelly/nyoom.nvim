(local M {})

(fn M.quit []
  (let [bufnr (vim.api.nvim_get_current_buf)
        buf-windows (vim.call :win_findbuf bufnr)
        modified (vim.api.nvim_get_option_value :modified {:buf bufnr})]
    (if (and modified (= (length buf-windows) 1))
        (vim.ui.input {:prompt "You have unsaved changes. Quit anyway? (y/n) "}
                      (fn [input]
                        (when (= input :y)
                          (vim.cmd :qa!)))) (vim.cmd :qa!))))

(set M.safe_require (fn [module-name]
                      (let [(status-ok module) (pcall require module-name)]
                        (when (not status-ok)
                          (vim.notify (.. "Couldn't load module '" module-name
                                          "'"))
                          (do
                            (lua "return ")))
                        module)))

(fn M.get_short_cwd []
  (let [parts (vim.split (vim.fn.getcwd) "/")]
    (. parts (length parts))))

(fn M.buffer_dir []
  (let [bufnr (vim.api.nvim_get_current_buf)]
    (when (and (= (type bufnr) :number) (> bufnr 0))
      (local bufname (vim.api.nvim_buf_get_name bufnr))
      (when (and (= (type bufname) :string) (> (string.len bufname) 0))
        (local bufdir (vim.fn.fnamemodify bufname ":h"))
        (when (and (and (= (type bufdir) :string) (> (string.len bufdir) 0))
                   (> (vim.fn.isdirectory bufdir) 0))
          (lua "return bufdir"))))
    nil))

(fn M.project_dir []
  (let [(ok projdir) (pcall (fn []
                              ((. (require :project) :get_project_root))))]
    (if (and (and ok projdir) (= (vim.fn.isdirectory projdir) 1))
        (do
          (vim.notify (.. "Using project root: " projdir) vim.log.levels.INFO)
          projdir) (let [cwd (vim.loop.cwd)]
                            (vim.notify (.. "No project root found. Falling back to current working directory: "
                                            cwd)
                                        vim.log.levels.WARN)
                            cwd))))

(set M.notify
     (fn [message level title]
       (let [notify-options {:timeout 5000 : title}]
         (vim.schedule (fn []
                         (vim.notify message level notify-options))))))

(set M.Insert_uuid (fn []
                     (let [(row col) (unpack (vim.api.nvim_win_get_cursor 0))
                           uuid ((require :utils.uuid))]
                       (vim.api.nvim_buf_set_text 0 (- row 1) col (- row 1) col
                                                  [uuid]))))

(vim.keymap.set :i :<M-u> M.Insert_uuid {:noremap true :silent true})

(fn preserve [arguments]
  (let [args (string.format "keepjumps keeppatterns execute %q" arguments)]
    (var (line col) (unpack (vim.api.nvim_win_get_cursor 0)))
    (vim.api.nvim_command args)
    (local lastline (vim.fn.line "$"))
    (when (> line lastline)
      (set line lastline))
    (print "line:" line)
    (print "col:" col)
    (vim.api.nvim_win_set_cursor 0 [line col])))

(set M.cursor_pos
     (fn []
       (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
         (print "line:" line)
         (print "col:" col)
         (print "col:" (+ col 7))
         (vim.api.nvim_win_set_cursor 0 [line 7]))))

(set M.update_meta (fn []
                     (when (not (vim.api.nvim_buf_option_value (vim.api.nvim_get_current_buf)
                                                               :modifiable))
                       (lua "return "))
                     (when (>= (vim.fn.line "$") 7)
                       (os.setlocale :en_US.UTF-8)
                       (local time (os.date "%Y-%m-%d"))
                       (preserve (.. "sil! keepp keepj 1,20s/\\vlast_edited_date:\\zs.*/ "
                                     time :/ei))
                       (preserve (.. "sil! keepp keepj 1,20s/\\vrev-date:\\zs.*/ "
                                     time :/ei)))))

(fn M.spellcheck_enabled []
  vim.o.spell)

(fn M.Auto_split []
  (if (> (vim.api.nvim_win_get_width 0)
         (math.floor (* (vim.api.nvim_win_get_height 0) 2.3)))
      (vim.cmd :vs) (vim.cmd :split)))

(fn M.Close_other_buffers []
  (let [current (vim.api.nvim_get_current_buf)]
    (each [_ buf (ipairs (vim.api.nvim_list_bufs))]
      (when (and (vim.api.nvim_buf_is_loaded buf) (not= buf current))
        (vim.api.nvim_buf_delete buf {:force false})))))

(fn M.show_messages []
  (let [lines (vim.split (vim.api.nvim_exec :messages true) "\n")]
    (when (= (length lines) 0)
      (lua "return "))
    (local buf (vim.api.nvim_create_buf false true))
    (vim.api.nvim_buf_set_lines buf 0 (- 1) false lines)
    (vim.cmd "botright split")
    (local win (vim.api.nvim_get_current_win))
    (vim.api.nvim_win_set_height win (math.min (length lines) 15))
    (vim.api.nvim_win_set_buf win buf)
    (tset (. vim.bo buf) :buftype :nofile)
    (tset (. vim.bo buf) :bufhidden :wipe)
    (tset (. vim.bo buf) :swapfile false)
    (tset (. vim.bo buf) :modifiable false)
    (vim.keymap.set :n :q :<cmd>close<cr> {:buffer buf :silent true})))

(fn M.extract_column [col2-start col3-start]
  (when (not col2-start)
    (set-forcibly! col2-start (tonumber (vim.fn.input "Column 2 start: "))))
  (when (not col3-start)
    (set-forcibly! col3-start (tonumber (vim.fn.input "Column 3 start: "))))
  (local buf (vim.api.nvim_get_current_buf))
  (local line-count (vim.api.nvim_buf_line_count buf))
  (local col2-text {})
  (local col3-text {})
  (for [i 0 (- line-count 1)]
    (local line (or (. (vim.api.nvim_buf_get_lines buf i (+ i 1) false) 1) ""))
    (local line-chars (vim.str_utfindex line))
    (local col2-start-safe (math.min (- col2-start 1) line-chars))
    (local col2-end-safe (math.min (- col3-start 2) line-chars))
    (local col2-slice
           (line:sub (+ (vim.str_byteindex line col2-start-safe) 1)
                     (vim.str_byteindex line col2-end-safe)))
    (table.insert col2-text col2-slice)
    (local col3-start-safe (math.min (- col3-start 1) line-chars))
    (local col3-slice (line:sub (+ (vim.str_byteindex line col3-start-safe) 1)))
    (table.insert col3-text col3-slice)
    (local col1-end-safe (math.max 0 (math.min (- col2-start 2) line-chars)))
    (local col1-slice (line:sub 1 (+ (vim.str_byteindex line col1-end-safe) 1)))
    (vim.api.nvim_buf_set_lines buf i (+ i 1) false [col1-slice]))
  (vim.api.nvim_buf_set_lines buf line-count line-count false [""])
  (local bottom-line (vim.api.nvim_buf_line_count buf))
  (vim.api.nvim_buf_set_lines buf bottom-line bottom-line false col2-text)
  (vim.api.nvim_buf_set_lines buf (+ bottom-line (length col2-text))
                              (+ bottom-line (length col2-text)) false col3-text))

(vim.keymap.set :n :<M-f> (fn []
                            (M.extract_column))
                {:noremap true :silent true})

(fn M.process_all_pages [lang]
  (let [base (vim.fn.expand "~/dev/jula/index-francais/")
        csv (.. base :/data/ lang :/columns.csv)
        pages-dir (.. base :/build/ lang :/pages)
        out-dir (.. base :/build/ lang :/processed)]
    (vim.fn.mkdir out-dir :p)
    (local lines (vim.fn.readfile csv))
    (each [_ entry (ipairs lines)]
      (when (not= entry "")
        (local (page c2 c3) (entry:match "([^,]+),([^,]+),([^,]+)"))
        (when (and (and page c2) c3)
          (local col2-start (tonumber c2))
          (local col3-start (tonumber c3))
          (local infile (.. pages-dir "/" page :.txt))
          (local outfile (.. out-dir "/" page :.txt))
          (local buf (vim.api.nvim_create_buf false true))
          (local file-lines (vim.fn.readfile infile))
          (vim.api.nvim_buf_set_lines buf 0 (- 1) false file-lines)
          (vim.api.nvim_set_current_buf buf)
          (M.extract_column col2-start col3-start)
          (local new-lines (vim.api.nvim_buf_get_lines buf 0 (- 1) false))
          (vim.fn.writefile new-lines outfile)
          (vim.api.nvim_buf_delete buf {:force true})
          (print (.. "Processed: " page)))))))

(fn M.get_plugin_path [name]
  (each [_ path (ipairs (vim.api.nvim_list_runtime_paths))]
    (when (path:match name)
      (lua "return path")))
  nil)

(fn M.open_branch_split [branch]
  (set-forcibly! branch (or branch :devold))
  (local filepath (vim.fn.expand "%"))
  (when (= filepath "")
    (print "No file open")
    (lua "return "))
  (vim.cmd :vsplit)
  (vim.cmd "wincmd l")
  (vim.cmd :enew)
  (vim.cmd "setlocal buftype=nofile bufhidden=hide noswapfile")
  (vim.cmd (.. "silent! read !git show " branch ":" filepath))
  (vim.cmd "1delete _")
  (local ft vim.bo.filetype)
  (vim.cmd (.. "setlocal filetype=" ft))
  (print (.. "Opened " filepath " from " branch)))

(vim.api.nvim_create_user_command :GitCompare
                                  (fn [opts]
                                    (M.open_branch_split (or (and (not= opts.args
                                                                        "")
                                                                  opts.args)
                                                             nil)))
                                  {:nargs "?"})

(vim.keymap.set :n :<leader>fb ":GitCompare devold<CR>"
                {:desc "Compare current file with devold"})

M

