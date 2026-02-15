(set _G.list_nyoom_mods
     (fn []
       (let [m (or (. _G :nyoom/modules) {})
             names {}]
         (each [name _ (pairs m)]
           (table.insert names name))
         (table.sort names)
         (local output (table.concat names "\n"))
         (if (= (length names) 0)
             (vim.notify "No modules found in _G['nyoom/modules']"
                         vim.log.levels.WARN)
             (vim.notify (.. "Active Modules:\n" output) vim.log.levels.INFO)))))

