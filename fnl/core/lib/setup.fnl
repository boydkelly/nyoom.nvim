(local {: autoload} (require :core.lib.autoload))
(local {: deep-merge} (autoload :core.lib.tables))

(fn setup [name ?config]
  (let [config (or ?config {})
        ;; Load the module
        module (autoload name)
        ;; Look for a 'setup' function inside the module,
        ;; or check if the module itself is the setup function
        setup-fn (if (= (type module.setup) :function)
                     module.setup
                     (= (type module) :function)
                     module
                     nil)]

    (if (not= setup-fn nil)
        (setup-fn (deep-merge (?. _G.shared.userconfigs name) config))
        (error (.. "Could not find a setup function for plugin: " name)))))

(fn after [name config]
  (tset _G.shared.userconfigs name config))

{: setup : after}

(fn after [name config]
  "Recreation of the `after!` macro for Nyoom.

  Accepts the following arguments:
  * `name`: the name of the plugin to set up
  * `config`: a table of configuration options to merge with the plugin's default configuration

  Example of use:
  ```fennel
  (after nvim-telescope {:config-to-merge})
  ```"
  (tset _G.shared.userconfigs name config))

{: setup : after}
