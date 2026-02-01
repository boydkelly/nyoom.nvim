(import-macros {: use-package!} :macros)

;; interactive lisp evaluation
(use-package! :Olical/conjure {:after tools.eval
                               :branch :develop
                               :ft [:fennel
                                    :clojure
                                    :lisp
                                    :rust
                                    :lua
                                    :julia
                                    :python]})
