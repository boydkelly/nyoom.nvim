(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; interactive lisp evaluation
(lz-package! :Olical/conjure {:nyoom-module tools.eval
                               :branch :develop
                               :enabled true
                               :ft [:fennel
                                    :clojure
                                    :lisp
                                    :rust
                                    :lua
                                    :julia
                                    :python]})
