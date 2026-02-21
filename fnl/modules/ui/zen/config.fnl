
(local {: setup} (require :core.lib.setup))
(local opts { :modes { :minimalist { :options { :showtabline 1 
                                                :cmdheight 0
                                                :laststatus 3}}}})
(setup :true-zen opts)
