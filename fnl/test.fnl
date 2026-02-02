(lambda lz-package! [identifier ?options]
  (let [options (or ?options {})
        id-str (->str identifier)

        ;; 1. Extract Requirements and Registrations
        req-list (or options.requires [])
        req-names []
        req-registrations []
        _ (each [_ req (ipairs req-list)]
            (let [expanded-req (if (list? req) (macroexpand req) req)]
              (if (= (type expanded-req) :table)
                  (do
                    (table.insert req-names expanded-req.name)
                    (table.insert req-registrations expanded-req.reg))
                  (table.insert req-names expanded-req))))

        ;; 2. Module/Setup Definitions
        ;; We use (sym? ...) check to ensure tools.tree-sitter doesn't crash the compiler
        module-name (if options.nyoom-module
                        (let [nm options.nyoom-module]
                          (if (sym? nm) (tostring nm) (->str nm)))
                        nil)
        setup-plugin (if options.call-setup (->str options.call-setup) nil)

        ;; 3. Name normalization for lz.n
        raw-name (or options.as (id-str:match ".*/(.*)") id-str)
        name (raw-name:lower)

        ;; 4. Build Hooks (beforeAll / before / after)
        run-cmd (if (sym? options.run) (->str options.run) options.run)
        build-file (if (sym? options.build-file) (->str options.build-file) options.build-file)

        before-all-hook (when run-cmd
                          (let [plugin-path (.. (vim.fn.stdpath :data)
                                                :/site/pack/core/opt/
                                                raw-name)]
                            `(fn []
                               (let [uv# (or vim.loop vim.uv)
                                     marker# (if ,build-file
                                                 (.. ,plugin-path "/" ,build-file)
                                                 (.. ,plugin-path :/.nyoom_built))]
                                 (when (not (uv#.fs_stat marker#))
                                   (print ,(.. "Building " raw-name "..."))
                                   (let [res# (vim.fn.system ,(.. "cd " plugin-path " && " run-cmd))]
                                     (when (not ,build-file)
                                       (let [f# (io.open marker# :w)]
                                         (f#:write (os.date))
                                         (f#:close)))))))))

        before-parts (let [p []]
                       (each [_ r-name (ipairs req-names)]
                         (table.insert p `((. (require :lz.n) :trigger_load) ,r-name)))
                       p)

        before-hook (if (> (length before-parts) 0)
                        `(fn [] ,(unpack before-parts)))

        after-parts (let [p []]
                      (when module-name
                        (table.insert p `(include ,(.. :fnl.modules. module-name :.config))))
                      (when setup-plugin
                        (table.insert p `(let [al# (require :core.lib.autoload)
                                               setup-lib# (al#.autoload :core.lib.setup)]
                                           (setup-lib#.setup ,setup-plugin {}))))
                      (when options.config
                        (table.insert p options.config))
                      p)

        after-hook (if (> (length after-parts) 0)
                       `(fn [] ,(unpack after-parts)))

        ;; 5. Build the spec table for lz.n
        spec-kv {1 name}]

    ;; Filter options and coerce values to strings
    ;; We exclude all internal keys so lz.n doesn't get confused
    (each [k v (pairs options)]
      (let [k-str (tostring k)]
        (when (and (not= k-str :after)
                   (not= k-str :nyoom-module)
                   (not= k-str :setup)
                   (not= k-str :requires)
                   (not= k-str :config)
                   (not= k-str :call-setup)
                   (not= k-str :defer)
                   (not= k-str :run)
                   (not= k-str :build-file)
                   (not= k-str :as))
          (let [v-safe (if (sym? v) (->str v) v)]
            (tset spec-kv k v-safe)))))

    ;; --- Logic: Defer Translation ---
    (when options.defer
      (tset spec-kv :event :DeferredUIEnter))

    ;; Inject names into the lazy-loader spec
    (when (> (length req-names) 0)
      (tset spec-kv :requires req-names))

    (if before-all-hook (tset spec-kv :beforeAll before-all-hook))
    (if before-hook (tset spec-kv :before before-hook))
    (if after-hook (tset spec-kv :after after-hook))

    ;; 6. The Generated Code Block
    (let [final-code `(do)]
      ;; Manually insert each registration into the 'do' block
      (each [_ reg (ipairs req-registrations)]
        (table.insert final-code reg))

      ;; Module registry for Nyoom internal tracking
      (when module-name
        (table.insert final-code
          `(let [m-def# {:config-paths [,(.. :fnl.modules. module-name :.config)]}]
             (tset _G.nyoom/modules ,module-name m-def#)
             (table.insert _G.nyoom/modules m-def#))))

      (table.insert final-code (vim-pack-spec! identifier options))
      (table.insert final-code `(table.insert _G.nyoom/specs ,spec-kv))

      ;; Return the final constructed 'do' block
      final-code)))
