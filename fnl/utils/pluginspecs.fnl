(local M {})

(local EXCLUDE {:hotpot.nvim true :lz.n true :tangerine.nvim true})

(fn read-lockfile [lock-file]
  (when (= (vim.fn.filereadable lock-file) 0)
    (let [___antifnl_rtn_1___ nil
          ___antifnl_rtn_2___ (.. "lockfile not found: " lock-file)]
      (lua "return ___antifnl_rtn_1___, ___antifnl_rtn_2___")))
  (local (ok contents) (pcall vim.fn.readfile lock-file))
  (when (not ok)
    (let [___antifnl_rtn_1___ nil
          ___antifnl_rtn_2___ (.. "failed to read lockfile: " lock-file)]
      (lua "return ___antifnl_rtn_1___, ___antifnl_rtn_2___")))
  (local (ok2 data) (pcall vim.json.decode (table.concat contents "\n")))
  (when (not ok2)
    (let [___antifnl_rtn_1___ nil
          ___antifnl_rtn_2___ (.. "failed to decode lockfile json: " lock-file)]
      (lua "return ___antifnl_rtn_1___, ___antifnl_rtn_2___")))
  data)

(fn manifest-to-set [manifest]
  (let [___set___ {}]
    (each [_ entry (ipairs (or manifest {}))]
      (var name nil)
      (if (= (type entry) :string) (set name (entry:match ".*/(.*)"))
          (= (type entry) :table)
          (if entry.name (set name entry.name)
              entry.src (set name (entry.src:match ".*/(.*)"))
              (. entry 1) (set name (: (. entry 1) :match ".*/(.*)"))))
      (when name
        (tset ___set___ name true)))
    ___set___))

(fn backup-file [path]
  (let [ts (os.date "%Y%m%dT%H%M%S")
        filename (vim.fn.fnamemodify path ":t")
        dest (.. :/var/tmp/ filename :.bak. ts)
        cmd (string.format "cp '%s' '%s'" path dest)
        ret (os.execute cmd)]
    (when (or (= ret 0) (= ret true))
      (os.execute (string.format "rm -f %s/%s.bak.*"
                                 (vim.fn.fnamemodify path ":h") filename))
      (lua "return dest"))
    (values nil "Failed to copy to /var/tmp")))

(fn M.clean [opts]
  (set-forcibly! opts (or opts {}))
  (var dry opts.dry)
  (when (= dry nil)
    (set dry true))
  (local force (or opts.force false))
  (var do-backup opts.backup)
  (when (= do-backup nil)
    (set do-backup true))
  (local (ok manifest-mod) (pcall require :config.plugins))
  (when (or (or (not ok) (not manifest-mod))
            (not= (type manifest-mod.plugins) :table))
    (vim.notify "cleanplugins: failed to load manifest at require('config.plugins').plugins"
                vim.log.levels.ERROR)
    (lua "return "))
  (local desired (manifest-to-set manifest-mod.plugins))
  (local lock-file (.. (vim.fn.stdpath :config) :/nvim-pack-lock.json))
  (local (lock-data err) (read-lockfile lock-file))
  (when (not lock-data)
    (vim.notify (.. "cleanplugins: " err) vim.log.levels.WARN)
    (lua "return "))
  (local installed (or lock-data.plugins {}))
  (local to-remove {})
  (each [name _ (pairs installed)]
    (when (and (not (. desired name)) (not (. EXCLUDE name)))
      (table.insert to-remove name)))
  (when (= (length to-remove) 0)
    (vim.notify "cleanplugins: nothing to remove" vim.log.levels.INFO)
    (lua "return "))
  (when do-backup
    (local (bak berr) (backup-file lock-file))
    (if bak (vim.notify (.. "cleanplugins: lockfile backed up to " bak)
                        vim.log.levels.DEBUG)
        (vim.notify (.. "cleanplugins: backup failed: " (tostring berr))
                    vim.log.levels.WARN)))
  (when (and dry (not force))
    (local msg ["cleanplugins (dry run) - plugins that would be removed:"])
    (each [_ name (ipairs to-remove)]
      (table.insert msg (.. "  - " name)))
    (vim.notify (table.concat msg "\n") vim.log.levels.WARN)
    (let [___antifnl_rtn_1___ to-remove]
      (lua "return ___antifnl_rtn_1___")))
  (local removed {})
  (each [_ name (ipairs to-remove)]
    (local (ok-del err-del) (pcall vim.pack.del [name]))
    (if ok-del (do
                 (table.insert removed name)
                 (vim.notify (.. "cleanplugins: removed " name)
                             vim.log.levels.INFO))
        (vim.notify (.. "cleanplugins: failed to remove " name ": "
                        (tostring err-del))
                    vim.log.levels.ERROR)))
  removed)

(fn M.cmd [arg]
  (var opts {})
  (if (= (type arg) :table) (set opts arg)
      (= arg true) (do
                     (set opts.force true)
                     (set opts.dry false)))
  (M.clean opts))

M

