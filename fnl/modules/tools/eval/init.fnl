(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

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
