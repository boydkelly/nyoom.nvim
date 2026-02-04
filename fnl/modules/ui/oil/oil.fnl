[{1 :oil.nvim
  :after (fn []
           ((. (require :lz.n) :trigger_load) :edgy)
           (require :setup.oil))
  :enabled true
  :keys [{1 "-"
          2 (fn []
              (_G.toggle_oil_split))
          :desc "Toggle Oil"}
         {1 :<leader>fe
          2 (fn []
              (_G.toggle_oil_split))
          :desc "Toggle Oil"}]
  :lazy true}]

