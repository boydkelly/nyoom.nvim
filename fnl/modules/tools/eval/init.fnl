(import-macros {: lz-package! : vim-pack-spec!} :macros)

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
