(defmacro nyoom-prelude []
  `(local {: nil? empty? nth executable? setup autoload}
     (require :core.lib)))
