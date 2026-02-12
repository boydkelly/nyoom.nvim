(local {: nil?
        : str?
        : bool?
        : num?
        : ->str
        : begins-with?
        : crypt
        : all
        : car} (require :core.lib))

(lambda fake-module! [name]
  "Directly includes a module's config file at compile-time.
   Used for modules that only contain settings, autocommands, or keymaps."
  (assert-compile (sym? name) "expected symbol for name" name)
  (let [name-str (tostring name)
        ;; We use the same path structure as lz-package!
        config-path (.. :modules. name-str :.config)]
    `(include ,config-path)))

(lambda expr->str [expr]
  `(-> (macrodebug ,expr nil (string.gsub "{}" "[]")
                   (string.gsub "_%d+_auto" "#"))))

(lambda extend-fn [fn-name args & body]
  (assert-compile (sym? fn-name) "expected symbol for fn-name" fn-name)
  (assert-compile (sequence? args) "expected list for args" args)
  (assert-compile (> (length body) 0) "expected at least one statement" body)
  (table.insert body `(values (unpack result#)))
  `(let [old# ,fn-name]
     (set ,fn-name (fn [...]
                     (local result# [(old# ...)])
                     (local [,(unpack args)] result#)
                     ,(unpack body)))
     ,fn-name))

(lambda fn? [x]
  "Checks if `x` is a function definition.
  Cannot check if a symbol is a function in compile time."
  (and (list? x) (or (= `fn (car x)) (= `hashfn (car x)) (= `lambda (car x))
                     (= `partial (car x)))))

(lambda quoted? [x]
  "Check if `x` is a list that begins with `quote`."
  (and (list? x) (= `quote (car x))))

(lambda quoted->fn [expr]
  "Converts an expression like `(quote (+ 1 1))` into `(fn [] (+ 1 1))`."
  (assert-compile (quoted? expr) "expected quoted expression for expr" expr)
  (let [non-quoted (. expr 2)]
    `(fn []
       ,non-quoted)))

(lambda quoted->str [expr]
  "Converts a quoted expression like `(quote (+ 1 1))` into an string with its shorthand form."
  (assert-compile (quoted? expr) "expected quoted expression for expr" expr)
  (let [non-quoted (. expr 2)]
    (.. "'" (view non-quoted))))

(lambda expand-exprs [exprs]
  "Converts a list of expressions into either an expression - if only one
  expression is in the list - or a do-expression containing the expressions."
  (if (> (length exprs) 1)
      `(do
         ,(unpack exprs))
      (car exprs)))

(lambda gensym-checksum [x ?options]
  "Generates a new symbol from the checksum of the object passed as a parameter
  after it is casted into an string using the `view` function.
  You can also pass a prefix or a suffix into the options optional table.
  This function depends on the djb2 hash function."
  (let [options (or ?options {})
        prefix (or options.prefix "")
        suffix (or options.suffix "")]
    (sym (.. prefix (crypt.djb2 (view x)) suffix))))

(lambda vlua [x]
  "Return a symbol mapped to `v:lua.%s()` where `%s` is the symbol."
  (assert-compile (sym? x) "expected symbol for x" x)
  (string.format "v:lua.%s()" (->str x)))

(lambda colorscheme [scheme]
  "Set a colorscheme using the vim.api.nvim_cmd API.
  Accepts the following arguements:
  scheme -> a symbol.
  Example of use:
  ```fennel
  (colorscheme carbon)
  ```"
  (assert-compile (sym? scheme) "expected symbol for name" scheme)
  (let [scheme (->str scheme)]
    `(vim.api.nvim_cmd {:cmd :colorscheme :args [,scheme]} {})))

(lambda custom-set-face! [name attributes colors]
  "Sets a highlight group globally using the vim.api.nvim_set_hl API.
  Accepts the following arguments:
  name -> a string.
  attributes -> a list of boolean attributes:
    - bold
    - italic
    - reverse
    - inverse
    - standout
    - underline
    - underlineline
    - undercurl
    - underdot
    - underdash
    - strikethrough
    - default
  colors -> a table of colors:
    - fg
    - bg
    - ctermfg
    - ctermbg
  Example of use:
  ```fennel
  (custom-set-face! Error [:bold] {:fg \"#ff0000\"})
  ```
  That compiles to:
  ```fennel
  (vim.api.nvim_set_hl 0 \"Error\" {:fg \"#ff0000\"
                                    :bold true})
  ```"
  (assert-compile (str? name) "expected string for name" name)
  (assert-compile (table? attributes) "expected table for attributes"
                  attributes)
  (assert-compile (table? colors) "expected colors for colors" colors)
  (let [definition (collect [_ attr (ipairs attributes) &into colors]
                     (->str attr)
                     true)]
    `(vim.api.nvim_set_hl 0 ,name ,definition)))

(lambda set! [name ?value]
  "Set a vim option using the vim.opt.<name> API.
  Accepts the following arguments:
  name -> must be a symbol.
          - If it ends with '+' it appends to the current value.
          - If it ends with '-' it removes from the current value.
          - If it ends with with '^' it prepends to the current value.
  value -> anything.
           - If it is not specified, whether the name begins with 'no' is used
             as a boolean value.
           - If it is a quoted expression or a function it becomes
             v:lua.<symbol>()."
  (assert-compile (sym? name) "expected symbol for name" name)
  (let [name (->str name)
        value (if (nil? ?value)
                  (not (begins-with? :no name))
                  ?value)
        value (if (quoted? value)
                  (quoted->fn value)
                  value)
        name (if (and (nil? ?value) (begins-with? :no name))
                 (name:match "^no(.+)$")
                 name)
        exprs (if (fn? value) [`(tset _G
                                      ,(->str (gensym-checksum value
                                                               {:prefix "__"}))
                                      ,value)] [])
        value (if (fn? value)
                  (vlua (gensym-checksum value {:prefix "__"}))
                  value)
        exprs (doto exprs
                (table.insert (match (name:sub -1)
                                "+" `(: (. vim.opt ,(name:sub 1 -2)) :append
                                        ,value)
                                "-" `(: (. vim.opt ,(name:sub 1 -2)) :remove
                                        ,value)
                                "^" `(: (. vim.opt ,(name:sub 1 -2)) :prepend
                                        ,value)
                                _ `(tset vim.opt ,name ,value))))]
    (expand-exprs exprs)))

(lambda local-set! [name ?value]
  "Set a vim option using the vim.opt_local.<name> API.
  Accepts the following arguments:
  name -> must be a symbol.
          - If it ends with '+' it appends to the current value.
          - If it ends with '-' it removes from the current value.
          - If it ends with with '^' it prepends to the current value.
  value -> anything.
           - If it is not specified, whether the name begins with 'no' is used
             as a boolean value.
           - If it is a quoted expression or a function it becomes
             v:lua.<symbol>()."
  (assert-compile (sym? name) "expected symbol for name" name)
  (let [name (->str name)
        value (if (nil? ?value)
                  (not (begins-with? :no name))
                  ?value)
        value (if (quoted? value)
                  (quoted->fn value)
                  value)
        name (if (and (nil? ?value) (begins-with? :no name))
                 (name:match "^no(.+)$")
                 name)
        exprs (if (fn? value) [`(tset _G
                                      ,(->str (gensym-checksum value
                                                               {:prefix "__"}))
                                      ,value)] [])
        value (if (fn? value)
                  (vlua (gensym-checksum value {:prefix "__"}))
                  value)
        exprs (doto exprs
                (table.insert (match (name:sub -1)
                                "+" `(: (. vim.opt_local ,(name:sub 1 -2))
                                        :append ,value)
                                "-" `(: (. vim.opt_local ,(name:sub 1 -2))
                                        :remove ,value)
                                "^" `(: (. vim.opt_local ,(name:sub 1 -2))
                                        :prepend ,value)
                                _ `(tset vim.opt_local ,name ,value))))]
    (expand-exprs exprs)))

(lambda shared-command! [api-function name command ?options]
  (assert-compile (sym? api-function) "expected symbol for api-function"
                  api-function)
  (assert-compile (sym? name) "expected symbol for name" name)
  (assert-compile (or (str? command) (sym? command) (fn? command)
                      (quoted? command))
                  "expected string, symbol, function or quoted expression for command"
                  command)
  (assert-compile (or (nil? ?options) (table? ?options))
                  "expected table for options" ?options)
  (let [name (->str name)
        options (or ?options {})
        options (if (nil? options.desc)
                    (doto options
                      (tset :desc
                            (if (quoted? command) (quoted->str command)
                                (str? command) command
                                (view command))))
                    options)
        command (if (quoted? command) (quoted->fn command) command)]
    `(,api-function ,name ,command ,options)))

(lambda command! [name command ?options]
  "Create a new user command using the vim.api.nvim_create_user_command API.

  Accepts the following arguments:
  name -> must be a symbol.
  command -> can be an string, a symbol, a function or a quoted expression.
  options -> a table of options. Optional. If the :desc option is not specified
             it will be inferred.

  Example of use:
  ```fennel
  (command! Salute '(print \"Hello World\")
            {:bang true :desc \"This is a description\"})
  ```
  That compiles to:
  ```fennel
  (vim.api.nvim_create_user_command \"Salute\" (fn [] (print \"Hello World\"))
                                    {:bang true
                                     :desc \"This is a description\"})
  ```"
  (shared-command! `vim.api.nvim_create_user_command name command ?options))

(lambda local-command! [name command ?options]
  "Create a new user command using the vim.api.nvim_buf_create_user_command API.

  Accepts the following arguments:
  name -> must be a symbol.
  command -> can be an string, a symbol, a function or a quoted expression.
  options -> a table of options. Optional. If the :desc option is not specified
             it will be inferred.

  Example of use:
  ```fennel
  (local-command! Salute '(print \"Hello World\")
                  {:bang true :desc \"This is a description\"})
  ```
  That compiles to:
  ```fennel
  (vim.api.nvim_buf_create_user_command \"Salute\" (fn [] (print \"Hello World\"))
                                        {:bang true
                                         :desc \"This is a description\"})
  ```"
  (shared-command! `vim.api.nvim_buf_create_user_command name command ?options))

(lambda autocmd! [event pattern command ?options]
  "Create an autocommand using the nvim_create_autocmd API.

  Accepts the following arguments:
  event -> can be either a symbol or a list of symbols.
  pattern -> can be either a symbol or a list of symbols. If it's <buffer> the
             buffer option is set to 0. If the buffer option is set this value
             is ignored.
  command -> can be an string, a symbol, a function or a quoted expression.
  options -> a table of options. Optional. If the :desc option is not specified
             it will be inferred.

  Example of use:
  ```fennel
  (autocmd! VimEnter *.py '(print \"Hello World\")
            {:once true :group \"custom\" :desc \"This is a description\"})
  ```
  That compiles to:
  ```fennel
  (vim.api.nvim_create_autocmd :VimEnter
                               {:pattern \"*.py\"
                                :callback (fn [] (print \"Hello World\"))
                                :once true
                                :group \"custom\"
                                :desc \"This is a description\"})
  ```"
  (assert-compile (or (sym? event) (and (table? event) (all #(sym? $) event))
                      "expected symbol or list of symbols for event" event))
  (assert-compile (or (sym? pattern)
                      (and (table? pattern) (all #(sym? $) pattern))
                      "expected symbol or list of symbols for pattern" pattern))
  (assert-compile (or (str? command) (sym? command) (fn? command)
                      (quoted? command))
                  "expected string, symbol, function or quoted expression for command"
                  command)
  (assert-compile (or (nil? ?options) (table? ?options))
                  "expected table for options" ?options)
  (let [event (if (and (table? event) (not (sym? event)))
                  (icollect [_ v (ipairs event)]
                    (->str v))
                  (->str event))
        pattern (if (and (table? pattern) (not (sym? pattern)))
                    (icollect [_ v (ipairs pattern)]
                      (->str v))
                    (->str pattern))
        options (or ?options {})
        options (if (nil? options.buffer)
                    (if (= :<buffer> pattern)
                        (doto options
                          (tset :buffer 0))
                        (doto options
                          (tset :pattern pattern)))
                    options)
        options (if (str? command)
                    (doto options
                      (tset :command command))
                    (doto options
                      (tset :callback
                            (if (quoted? command)
                                (quoted->fn command)
                                command))))
        options (if (nil? options.desc)
                    (doto options
                      (tset :desc
                            (if (quoted? command) (quoted->str command)
                                (str? command) command
                                (view command))))
                    options)]
    `(vim.api.nvim_create_autocmd ,event ,options)))

(lambda augroup! [name ...]
  "Create an augroup using the nvim_create_augroup API.
  Accepts either a name or a name and a list of autocmd statements.

  Example of use:
  ```fennel
  (augroup! a-nice-group
    (autocmd! Filetype *.py '(print \"Hello World\"))
    (autocmd! Filetype *.sh '(print \"Hello World\")))
  ```
  That compiles to:
  ```fennel
  (do
    (vim.api.nvim_create_augroup \"a-nice-group\" {:clear false})
    (autocmd! Filetype *.py '(print \"Hello World\") {:group \"a-nice-group\"})
    (autocmd! Filetype *.sh '(print \"Hello World\") {:group \"a-nice-group\"}))
  ```"
  (assert-compile (or (str? name) (sym? name))
                  "expected string or symbol for name" name)
  (assert-compile (all #(and (list? $)
                             (or (= `clear! (car $)) (= `autocmd! (car $))))
                       [...])
                  "expected autocmd exprs for body" ...)
  (expand-exprs (let [name (->str name)]
                  (icollect [_ expr (ipairs [...])
                             &into [`(vim.api.nvim_create_augroup ,name
                                                                  {:clear false})]]
                    (if (= `autocmd! (car expr))
                        (let [[_ event pattern command ?options] expr
                              options (or ?options {})
                              options (doto options
                                        (tset :group name))]
                          `(autocmd! ,event ,pattern ,command ,options))
                        (let [[_ ?options] expr]
                          `(clear! ,name ,?options)))))))

(lambda clear! [name ?options]
  "Clears an augroup using the nvim_clear_autocmds API.

  Example of use:
  ```fennel
  (clear! some-group)
  ```
  That compiles to:
  ```fennel
  (vim.api.nvim_clear_autocmds {:group \"some-group\"})
  ```"
  (assert-compile (or (str? name) (sym? name))
                  "expected string or symbol for name" name)
  (assert-compile (or (nil? ?options) (table? ?options))
                  "expected table for options" ?options)
  (let [name (->str name)
        options (or ?options {})
        options (doto options
                  (tset :group name))]
    `(vim.api.nvim_clear_autocmds ,options)))

(lambda pack [identifier ?options]
  "Return a mixed table with the identifier as the car sequential element and
  options as hash-table items.
  See https://github.com/wbthomason/packer.nvim for information about the
  options.
  Additional to those options are some use-package-isms and custom keys:
  :defer to defer loading a plugin until a file is loaded
  :call-setup to call setup for a plugin using nyoom's setup wrapper
  nyoom-module to load the config for nyoom module"
  (assert-compile (str? identifier) "expected string for identifier" identifier)
  (if (not (nil? ?options))
      (assert-compile (table? ?options) "expected table for options" ?options))
  (let [options (or ?options {})
        options (collect [k v (pairs options)]
                  (match k
                    :call-setup (values :config
                                        (string.format "require(\"core.lib.autoload\")[\"autoload\"](\"core.lib.setup\")[\"setup\"](\"%s\", {})"
                                                       (->str v)))
                    :nyoom-module (values :config
                                          (string.format "require(\"modules.%s.config\")"
                                                         (->str v)))
                    :defer (values :setup
                                   (let [package (->str v)]
                                     `(lambda []
                                        (vim.api.nvim_create_autocmd [:BufRead
                                                                      :BufWinEnter
                                                                      :BufNewFile]
                                                                     {:group (vim.api.nvim_create_augroup ,package
                                                                                                          {})
                                                                      :callback (fn []
                                                                                  (if (not= vim.fn.expand
                                                                                            "%"
                                                                                            "")
                                                                                      (vim.defer_fn (fn []
                                                                                                      ((. (require :packer)
                                                                                                          :loader) ,package)
                                                                                                      (if (= ,package
                                                                                                             :nvim-lspconfig)
                                                                                                          (vim.cmd "silent! do FileType")))
                                                                                        0)))}))))
                    _ (values k v)))]
    (doto options
      (tset 1 identifier))))

(lambda rock [identifier ?options]
  "Return a mixed table with the identifier as the car sequential element and
  options as hash-table items.
  See https://github.com/wbthomason/packer.nvim for information about the
  options."
  (assert-compile (str? identifier) "expected string for identifier" identifier)
  (if (not (nil? ?options))
      (assert-compile (table? ?options) "expected table for options" ?options))
  (let [options (or ?options {})]
    (doto options
      (tset 1 identifier))))

; (lambda use-package! [identifier ?options]
;   "Declares a plugin with its options. This macro adds it to the nyoom/pack
;   global table to later be used in the `unpack!` macro.
;   See https://github.com/wbthomason/packer.nvim for information about the
;   options."
;   (assert-compile (str? identifier) "expected string for identifier" identifier)
;   (if (not (nil? ?options))
;       (assert-compile (table? ?options) "expected table for options" ?options))
;   (table.insert _G.nyoom/pack (pack identifier ?options)))

;; Macro: vim-pack-spec!
(lambda vim-pack-spec! [identifier ?options]
  "Inserts the specs from lz-package into _G.nyoom/pack for loading with lz.n"
  "Native package spec. Supports full URLs (GitLab/SourceHut) or GitHub shortcuts."
  (let [;; 1. Determine the URL
        url (if (or (identifier:match :^http) (identifier:match "^git@"))
                identifier
                (.. "https://github.com/" identifier))
        ;; 2. Extract the name
        raw-name (url:match ".*/([^/.-]+)%.?g?i?t?$") ;; ADD :lower() here
        name (let [n (or raw-name (url:match ".*/(.*)$"))]
               (n:lower))
        spec {:src url : name}]
    ;; 3. Check for version OR branch
    (when (table? ?options)
      (let [ver (or ?options.version ?options.branch)]
        (when ver
          (set spec.version ver))))
    `(table.insert _G.nyoom/pack ,spec)))

(lambda lz-trigger-load! [identifier ?options]
  "this is the basic call for the requires key.  If a package is required, it must be
  installed with vim pack. the lz-package macro will process the require and create an lz.n
  trigger_load function in the before function. This is suitable for extensions that do not require setup.
  Otherwise use lz-pack."
  (let [options (or ?options {})
        raw-name (or options.as (identifier:match ".*/(.*)") identifier)
        ;; ADD :lower() here
        name (raw-name:lower)]
    ;; Return a table that lz-package! can destructure
    {: name :reg (vim-pack-spec! identifier options)}))

(lambda lz-pack [identifier ?options]
  "Identical to legacy pack, but returns a table structured for lz-package! destructuring.
  Processes :nyoom-module, :call-setup, and :defer before passing to vim-pack-spec!"
  (assert-compile (str? identifier) "expected string for identifier" identifier)
  (if (not (nil? ?options))
      (assert-compile (table? ?options) "expected table for options" ?options))
  (let [options (or ?options {})
        ;; Calculate the name (same logic as lz-trigger-load!)
        raw-name (or options.as (identifier:match ".*/(.*)") identifier)
        name (raw-name:lower)
        ;; Transform the options exactly like the original pack macro
        processed-options (collect [k v (pairs options)]
                            (match k
                              :call-setup (values :config
                                                  (string.format "require(\"core.lib.autoload\")[\"autoload\"](\"core.lib.setup\")[\"setup\"](\"%s\", {})"
                                                                 (->str v)))
                              :nyoom-module (values :config
                                                    (string.format "require(\"modules.%s.config\")"
                                                                   (->str v)))
                              :defer (values :setup
                                             (let [package (->str v)]
                                               `(lambda []
                                                  (vim.api.nvim_create_autocmd [:BufRead
                                                                                :BufWinEnter
                                                                                :BufNewFile]
                                                                               {:group (vim.api.nvim_create_augroup ,package
                                                                                                                    {})
                                                                                :callback (fn []
                                                                                            (if (not= (vim.fn.expand "%")
                                                                                                      "")
                                                                                                (vim.defer_fn (fn []
                                                                                                                ((. (require :packer)
                                                                                                                    :loader) ,package)
                                                                                                                (if (= ,package
                                                                                                                       :nvim-lspconfig)
                                                                                                                    (vim.cmd "silent! do FileType")))
                                                                                                  0)))}))))
                              _ (values k v)))]
    ;; Return the lz-style table
    {: name :reg (vim-pack-spec! identifier processed-options)}))

(lambda lz-package! [identifier ?options]
  (let [options (or ?options {})
        ;; 1. Preserve version/branch for the installer before filtering
        install-version (or options.version options.branch)
        id-str (->str identifier) ;; 2. Extract Requirements and Registrations
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
        ;; 3. Module & Setup Logic
        module-name (let [m (or options.nyoom-module options.after)]
                      (if m
                          (if (sym? m) (tostring m) (->str m))
                          nil))
        setup-plugin (if options.call-setup
                         (let [s options.call-setup]
                           (if (sym? s) (tostring s) (->str s)))
                         nil) ;; 4. Name normalization
        raw-name (or options.as (id-str:match ".*/(.*)") id-str)
        name (raw-name:lower) ;; 5. Hook Construction
        run-cmd (if (sym? options.run) (->str options.run) options.run)
        build-file (if (sym? options.build-file) (->str options.build-file)
                       options.build-file)
        ;; 5. Hook Construction
        before-all-hook (when run-cmd
                          (let [plugin-path (.. (vim.fn.stdpath :data)
                                                :/site/pack/core/opt/ raw-name)]
                            `(fn []
                               (let [uv# (or vim.loop vim.uv)
                                     marker# (if ,build-file
                                                 (.. ,plugin-path "/"
                                                     ,build-file)
                                                 (.. ,plugin-path
                                                     :/.nyoom_built))]
                                 (when (not (uv#.fs_stat marker#))
                                   (vim.notify ,(.. "Building " raw-name "...")
                                               vim.log.levels.INFO)
                                   (let [cmd# (.. "sh -c 'cd " ,plugin-path
                                                  " && " (tostring ,run-cmd) "'")
                                         res# (vim.fn.system cmd#)]
                                     (if (not= vim.v.shell_error 0)
                                         (error (.. "Build failed for "
                                                    ,raw-name ": " res#))
                                         (do
                                           (vim.notify (.. "Successfully built "
                                                           ,raw-name)
                                                       vim.log.levels.INFO)
                                           (when (not ,build-file)
                                             (let [f# (io.open marker# :w)]
                                               (f#:write (os.date))
                                               (f#:close)))))))))))
        before-parts (let [p []]
                       (each [_ r-name (ipairs req-names)]
                         (table.insert p
                                       `((. (require :lz.n) :trigger_load) ,r-name)))
                       p)
        before-hook (if (> (length before-parts) 0)
                        `(fn [] ,(unpack before-parts)))
        after-parts (let [p []]
                      ;; 1. Handle Nyoom Module Include (nyoom-module/after)
                      (when module-name
                        (table.insert p
                                      `(require ,(.. :modules. module-name
                                                     :.config))))
                      ;; 2. Handle setup-plugin
                      (when setup-plugin
                        (table.insert p
                                      `(let [al# (require :core.lib.autoload)
                                             setup-lib# (al#.autoload :core.lib.setup)]
                                         (setup-lib#.setup ,setup-plugin {}))))
                      ;; 3. Handle :config (Always force modules. prefix)
                      (when options.config
                        (let [cfg (->str options.config)]
                          (table.insert p `(require ,(.. :modules. cfg)))))
                      ;; 4. Handle :after (Always force modules. prefix)
                      (when (and options.after
                                 (not= (->str options.after) module-name))
                        (let [aft (->str options.after)]
                          (table.insert p `(require ,(.. :modules. aft)))))
                      p) ;; The wrapper function logic
        after-hook (if (> (length after-parts) 0)
                       `(fn []
                          (do
                            ,(unpack after-parts))
                          nil))
        spec-kv {1 name}]
    ;; Fill lz.n spec while filtering out internal/installer keys
    (each [k v (pairs options)]
      (let [k-str (tostring k)]
        (when (and (not= k-str :nyoom-modules) (not= k-str :after)
                   (not= k-str :setup) (not= k-str :requires)
                   (not= k-str :config) (not= k-str :call-setup)
                   (not= k-str :run) (not= k-str :module) (not= k-str :branch)
                   (not= k-str :version) (not= k-str :opt)
                   (not= k-str :build-file) (not= k-str :defer) (not= k-str :as))
          (let [v-safe (if (sym? v) (->str v) v)]
            (tset spec-kv k v-safe)))))
    (when options.defer (tset spec-kv :event :DeferredUIEnter))
    (if before-all-hook (tset spec-kv :beforeAll before-all-hook))
    (if before-hook (tset spec-kv :before before-hook))
    (if after-hook (tset spec-kv :after after-hook))
    ;; 7. Final Code Generation (Now inside the main let block)
    (let [final-code `(do
                        )]
      (each [_ reg (ipairs req-registrations)] (table.insert final-code reg)) ; (when module-name ;   (table.insert final-code ;                 `(let [m-def# {:config-paths [,(.. :modules. module-name
      ;                                                    :.config)]}] ;                    (tset _G.nyoom/modules ,module-name m-def#) ;                    (table.insert _G.nyoom/modules m-def#))))
      ;; Re-insert the version/branch for the installer call
      (let [installer-options (if install-version
                                  (let [t# {}]
                                    (each [k# v# (pairs options)]
                                      (tset t# k# v#))
                                    (tset t# :version install-version)
                                    t#)
                                  options)]
        (table.insert final-code (vim-pack-spec! identifier installer-options)))
      ;; nyoom spces for lz.n to process
      (table.insert final-code `(table.insert _G.nyoom/specs ,spec-kv))
      final-code)))

;
;; Macro: unpack!
(lambda lz-unpack! []
  "Native C-layer install and RTP load. No longer wipes the table to preserve counts."
  `(let [pack-list# _G.nyoom/pack]
     (when (and pack-list# (> (length pack-list#) 0))
       ;; 1. The Download/Sync (Native API)
       (vim.pack.add pack-list# {:load (fn [])})
       ;; 2. The Activation (packadd)
       (each [_# spec# (ipairs pack-list#)]
         (pcall vim.cmd.packadd spec#.name)))))

;; 2. The Main Orchestrator (Refined)
(lambda lz-load-specs! []
  "Finalizes the plugin setup by handing the specs to lz.n"
  `(let [(ok?# lz#) (pcall require :lz.n)]
     (if ok?#
         (lz#.load _G.nyoom/specs)
         (print "NYOOM: lz.n loader not found!"))))

(lambda rock! [identifier ?options]
  "Declares a rock with its options. This macro addssh it to the nyoom/rock
  global table to later be used in the `unpack!` macro.
  See https://github.com/wbthomason/packer.nvim for information about the
  options."
  (assert-compile (str? identifier) "expected string for identifier" identifier)
  (if (not (nil? ?options))
      (assert-compile (table? ?options) "expected table for options" ?options))
  (table.insert _G.nyoom/rock (rock identifier ?options)))

(lambda unpack! []
  "Initializes the plugin manager with the plugins previously declared and
  their respective options."
  (let [packs (icollect [_ v (ipairs _G.nyoom/pack)]
                `(use ,v))
        rocks (icollect [_ v (ipairs _G.nyoom/rock)]
                `(use_rocks ,v))
        use-sym (sym :use)]
    `((. (require :packer) :startup) (fn [,use-sym]
                                       ,(unpack (icollect [_ v (ipairs packs)
                                                           &into rocks]
                                                  v))))))

(lambda packadd! [package]
  "Loads a package using the vim.api.nvim_cmd API.
  Accepts the following arguements:
  package -> a symbol.
  Example of use:
  ```fennel
  (packadd! packer.nvim)
  ```"
  (let [package (if (sym? package)
                    (->str package)
                    package)]
    `(vim.api.nvim_cmd {:cmd :packadd :args [,package]} {})))

(lambda pact-use-package! [identifier ?options]
  "use-package inspired package manager for nyoom, using pact.nvim

  Accepts the following arguments:
  identifier -> must be a string
  options -> a table of options. Optional

  Accepts the following options (pact):
  :name -> only required for raw `git` calls (not forge shortcuts), which defines the name to use in the `pact` ui (e.g. :fugitive)
  :branch -> branch to clone from. If no branch or additional versioning is specified, the default HEAD branch is cloned (e.g. :main)
  :tag -> git release tag to clone (e.g \"v3.7\")
  :commit -> full-length or shortened commit hash to clone (e.g. :ca82a6dff817ec66f44342007202690a93763949 or :ca82a6d)
  :version -> a semvar constraint (e.g. \"> 0.0.0\")
  :after -> either a string or function to run after a plugin is cloned or synced (e.g. \"sleep 2\")
  :opt? -> installs a package into /opt instead of /start, requires you to manually load the package (default false)

  Accepts the following additional options:
  :host -> which git forge to download from. Accepts git, github, gitlab, and srht. By default set to github
  :cmd -> cmd(s) to lazy load on. Accepts a string or sequential table
  :event -> vimscript event(s) to lazy load on. Accepts a string or sequential table
  :ft -> filetype(s) to lazy load on. Accepts a string or sequential table
  :bind -> shortcut to bind <leader> keymaps. Accepts a table with kv pairs
  :init -> code to run before package is loaded
  :config -> code to run after a package is loaded

  TODO:
  :keys
  :bind auto-lazy
  "
  (assert-compile (str? identifier) "expected string for identifier" identifier)
  (if (not (nil? ?options))
      (assert-compile (table? ?options) "expected table for options" ?options))
  (lambda cmd-load [cmd loadname]
    `(vim.api.nvim_create_user_command ,cmd
                                       (fn []
                                         (vim.api.nvim_del_user_command ,cmd)
                                         (vim.api.nvim_cmd {:cmd :packadd
                                                            :args [,loadname]}
                                                           {})
                                         (vim.cmd ,cmd))
                                       {:bang true :range true :nargs "*"}))
  (lambda event-load [event callback augroup]
    `(vim.api.nvim_create_autocmd ,event
                                  {:callback (,callback)
                                   :once true
                                   :group ,augroup}))
  (lambda ft-load [ft callback augroup]
    `(vim.api.nvim_create_autocmd :FileType
                                  {:pattern ,ft
                                   :callback (,callback)
                                   :once true
                                   :group ,augroup}))
  (lambda defer-load [x callback augroup loadname]
    (let [time (if (bool? x) 0 (if (num? x) x))
          doft (if (= loadname :nvim-lspconfig)
                   (vim.cmd "silent! do FileType"))]
      `(vim.api.nvim_create_autocmd [:BufRead :BufWinEnter :BufNewFile]
                                    {:group ,augroup
                                     :callback (fn []
                                                 (if (not= vim.fn.expand "%" "")
                                                     (vim.defer_fn (fn []
                                                                     (,callback)
                                                                     ,doft)
                                                       ,time)))})))
  (let [callback-sym (sym :*callback*)
        loadname (string.sub (string.match package "/.+") 2)
        augroup (.. :nyoom-pact- loadname)
        host :github
        autocmds `(do
                    )
        callback `(do
                    )
        result `(do
                  )
        options (or ?options {})
        options (collect [k v (pairs options)]
                  (match k
                    ;;                     :host (local host v)
                    ;;                     :cmd (table.insert autocmds (cmd-load v loadname))
                    ;;                     :event (table.insert autocmds
                    ;;                                       (event-load v callback-sym augroup))
                    ;;                     :ft (table.insert autocmds (ft-load v callback-sym augroup))
                    ;;                     :defer (table.insert autocmds
                    ;;                                          (defer-load v callback-sym augroup
                    ;;                                                      loadname))
                    ;;                     :bind (each [bind cmd (pairs v)]
                    ;;                             (let [bind (.. :<leader> bind)
                    ;;                                   cmd (.. :<cmd> cmd :<CR>)]
                    ;;                               (table.insert result
                    ;;                                             `(vim.keymap.set [:n] ,bind ,cmd))))
                    :init
                    (table.insert result `,v)
                    :config
                    (table.insert callback `,v)
                    _
                    (values k v)))]
    (table.insert result `((. (autoload :pact) ,host) ,identifier ,options))
    (if (. options :opt?)
        (do
          (table.insert result
                        `(vim.api.nvim_create_augroup ,augroup {:clear true}))
          (table.insert result `(fn ,callback-sym
                                  []
                                  (vim.api.nvim_del_augroup_by_name ,augroup)
                                  (vim.api.nvim_cmd {:cmd :packadd
                                                     :args [,loadname]}
                                                    {})
                                  ,callback))
          (table.insert result `,autocmds))
        (table.insert result `,callback))
    result))

(lambda map! [[modes] lhs rhs ?options]
  "Add a new mapping using the vim.keymap.set API.

  Accepts the following arguments:
  modes -> is a sequence containing a symbol, each character of the symbol is
           a mode.
  lhs -> must be an string.
  rhs -> can be an string, a symbol, a function or a quoted expression.
  options -> a table of options. Optional. If the :desc option is not specified
             it will be inferred.

  Example of use:
  ```fennel
  (map! [nv] \"<leader>lr\" vim.lsp.references
        {:silent true :buffer 0 :desc \"This is a description\"})
  ```
  That compiles to:
  ```fennel
  (vim.keymap.set [:n :v] \"<leader>lr\" vim.lsp.references
                  {:silent true
                   :buffer 0
                   :desc \"This is a description\"})
  ```"
  (assert-compile (sym? modes) "expected symbol for modes" modes)
  (assert-compile (str? lhs) "expected string for lhs" lhs)
  (assert-compile (or (str? rhs) (sym? rhs) (fn? rhs) (quoted? rhs))
                  "expected string, symbol, function or quoted expression for rhs"
                  rhs)
  (assert-compile (or (nil? ?options) (table? ?options))
                  "expected table for options" ?options)
  (let [modes (icollect [char (string.gmatch (->str modes) ".")]
                char)
        options (or ?options {})
        options (if (nil? options.desc)
                    (doto options
                      (tset :desc
                            (if (quoted? rhs) (quoted->str rhs)
                                (str? rhs) rhs
                                (view rhs))))
                    options)
        rhs (if (quoted? rhs) (quoted->fn rhs) rhs)]
    `(vim.keymap.set ,modes ,lhs ,rhs ,options)))

(lambda buf-map! [[modes] lhs rhs ?options]
  "Add a new mapping using the vim.keymap.set API.
  Sets by default the buffer option.

  Accepts the following arguments:
  modes -> is a sequence containing a symbol, each character of the symbol is
           a mode.
  lhs -> must be an string.
  rhs -> can be an string, a symbol, a function or a quoted expression.
  options -> a table of options. Optional. If the :desc option is not specified
             it will be inferred.

  Example of use:
  ```fennel
  (map! [nv] \"<leader>lr\" vim.lsp.references
        {:silent true :desc \"This is a description\"})
  ```
  That compiles to:
  ```fennel
  (vim.keymap.set [:n :v] \"<leader>lr\" vim.lsp.references
                  {:silent true
                   :buffer 0
                   :desc \"This is a description\"})
  ```"
  (assert-compile (sym? modes) "expected symbol for modes" modes)
  (assert-compile (str? lhs) "expected string for lhs" lhs)
  (assert-compile (or (str? rhs) (sym? rhs) (fn? rhs) (quoted? rhs))
                  "expected string, symbol, function or quoted expression for rhs"
                  rhs)
  (assert-compile (or (nil? ?options) (table? ?options))
                  "expected table for options" ?options)
  (let [options (or ?options {})
        options (doto options
                  (tset :buffer 0))]
    (map! [modes] lhs rhs options)))

(lambda let-with-scope! [[scope] name value]
  (assert-compile (or (str? scope) (sym? scope))
                  "expected string or symbol for scope" scope)
  (assert-compile (or (= :b (->str scope)) (= :w (->str scope))
                      (= :t (->str scope)) (= :g (->str scope)))
                  "expected scope to be either b, w, t or g" scope)
  (assert-compile (or (str? name) (sym? name))
                  "expected string or symbol for name" name)
  (let [name (->str name)
        scope (->str scope)]
    `(tset ,(match scope
              :b `vim.b
              :w `vim.w
              :t `vim.t
              :g `vim.g) ,name ,value)))

(lambda let-global! [name value]
  (assert-compile (or (str? name) (sym? name))
                  "expected string or symbol for name" name)
  (let [name (->str name)]
    `(tset vim.g ,name ,value)))

(lambda let! [...]
  "Set a vim variable using the vim.<scope>.name API.
  Accepts the following arguments:
  [scope] -> optional. Can be either [g], [w], [t] or [b]. It's either a symbol
             or a string surrounded by square brackets.
  name -> either a symbol or a string.
  value -> anything.
  Example of use:
  ```fennel
  (let! hello :world)
  (let! [w] hello :world)
  ```
  That compiles to:
  ```fennel
  (tset vim.g :hello :world)
  (tset vim.w :hello :world)
  ```"
  (match [...]
    [[scope] name value] (let-with-scope! [scope] name value)
    [name value] (let-global! name value)
    _ (error "expected let! to have at least two arguments: name value")))

(lambda verify-dependencies! [dependencies]
  "Uses the vim.notify API to print a warning for every dependecy that is no
   available and then executes an early return from the module."
  `(let [dependencies# ,dependencies
         info# (debug.getinfo 1 :S)
         module-name# info#.source
         module-name# (module-name#:match "@(.*)")
         not-available# (icollect [_# dependency# (ipairs dependencies#)]
                          (when (not (pcall require dependency#))
                            dependency#))]
     (when (> (length not-available#) 0)
       (each [_# dependency# (ipairs not-available#)]
         (vim.notify (string.format "Could not load '%s' as '%s' is not available."
                                    module-name# dependency#)
                     vim.log.levels.WARN))
       (lua "return nil"))))

(lambda sh [...]
  "simple macro to run shell commands inside fennel"
  `(let [str# ,(accumulate [str# "" _ v# (ipairs [...])]
                 (if (in-scope? v#) `(.. ,str# " " ,v#)
                     (or (list? v#) (sym? v#)) (.. str# " " (tostring v#))
                     (= (type v#) :string) (.. str# " " (string.format "%q" v#))))
         fd# (io.popen str#)
         d# (fd#:read :*a)]
     (fd#:close)
     (string.sub d# 1 (- (length d#) 1))))

(lambda nyoom! [...]
  "Recreation of the `doom!` macro for Nyoom
  See modules.fnl for usage
  Accepts the following arguments:
  value -> anything.
  Example of use:
  ```fennel
  (nyoom! :catagory
          module
          (module +with +flags
          :anothercatagory
          anothermodule
          (module +with +more +flags)
  ```"
  (var moduletag nil)
  (var registry {})

  (fn register-module [name]
    (if (str? name)
        (set moduletag name)
        (if (sym? name)
            (let [name (->str name)
                  include-path (.. :modules. moduletag "." name)
                  config-path (.. :modules. moduletag "." name :.config)]
              (tset registry name
                    {:include-paths [include-path] :config-paths [config-path]}))
            (let [modulename (->str (car name))
                  include-path (.. :modules. moduletag "." modulename)
                  config-path (.. :modules. moduletag "." modulename :.config)
                  [_ & flags] name]
              (var includes [include-path])
              (var configs [config-path])
              (each [_ v (ipairs flags)]
                (let [flagmodule (.. modulename "." (->str v))
                      flag-include-path (.. include-path "." (->str v))
                      flag-config-path (.. :modules. moduletag "." flagmodule
                                           :.config)]
                  (table.insert includes flag-include-path)
                  (table.insert configs flag-config-path)
                  (tset registry flagmodule {})))
              (tset registry modulename
                    {:include-paths includes :config-paths configs})))))

  (fn register-modules [...]
    (each [_ mod (ipairs [...])]
      (register-module mod))
    registry)

  (let [modules (register-modules ...)]
    (tset _G :nyoom/modules modules)))

(lambda lz-init-modules! []
  "Bakes the init.fnl files for all enabled modules."
  (fn init-module [module-name module-def]
    (icollect [_ include-path (ipairs (or module-def.include-paths []))]
      `(include ,include-path)))

  (fn init-modules [registry]
    (let [inits []]
      (each [_ module-def (pairs registry)]
        (let [items (init-module _ module-def)]
          (each [_ expr (ipairs items)]
            (table.insert inits expr))))
      inits))

  (let [inits (init-modules _G.nyoom/modules)]
    (expand-exprs inits)))

(lambda lz-config-modules! []
  "Statically inlines all config.fnl files. Hard-fails on missing/broken files."
  (fn config-module [_ module-def]
    (icollect [_ path (ipairs (or module-def.config-paths []))]
      `(include ,path)))

  (let [registry (or _G.nyoom/modules {})
        configs (icollect [name def (pairs registry)]
                  (config-module name def))]
    (expand-exprs (collect [_ list (ipairs configs) &into []]
                    (unpack list)))))

(lambda lz-compile-modules! []
  "Bakes config.fnl files directly from the registry table.
   No FS checks, no overhead—just static inclusion."
  (fn compile-module [module-name module-decl]
    (icollect [_ path (ipairs (or module-decl.config-paths []))]
      `(pcall (fn [] (include ,path)))))

  (fn compile-modules [registry]
    (let [source []]
      (each [_ module-def (pairs registry)]
        (let [configs (compile-module _ module-def)]
          (each [_ expr (ipairs configs)]
            (table.insert source expr))))
      source))

  (let [source (compile-modules (or _G.nyoom/modules {}))]
    (expand-exprs source)))

; (lambda lz-compile-modules-v1! []
;   "Bakes config.fnl files by checking the filesystem with libuv (fast)."
;   (let [uv vim.loop ;; Get the base path once at the start of the macro
;         config-path (.. (vim.fn.stdpath :config) :/fnl/)]
;     (fn file-exists? [mod-path]
;       (let [;; Convert 'modules.lang.sh.config' to 'modules/lang/sh/config.fnl'
;             rel-path (.. (mod-path:gsub "%." "/") :.fnl)
;             full-path (.. config-path rel-path)]
;         (not= nil (uv.fs_stat full-path))))
;
;     (fn compile-module [module-name module-decl]
;       (let [exprs []]
;         (each [_ path (ipairs (or module-decl.config-paths []))]
;           (if (file-exists? path)
;               (table.insert exprs `(pcall (fn [] (include ,path))))))
;         exprs))
;
;     (fn compile-modules [registry]
;       (let [source []]
;         (each [_ module-def (pairs registry)]
;           (let [configs (compile-module _ module-def)]
;             (each [_ expr (ipairs configs)]
;               (table.insert source expr))))
;         source))
;
;     (let [source (compile-modules _G.nyoom/modules)]
;       (expand-exprs source))))

(lambda nyoom-module! [name]
  "By default modules should be loaded through use-package!. Of course, not every
  modules needs a package. Sometimes we just want to load `config.fnl`. In this
  case, we can hack onto packer.nvim, give it a fake package, and ask it to load a
  config file.
  Example of use:
  ```fennel
  (nyoom-module! tools.tree-sitter)
  ```"
  (assert-compile (sym? name) "expected symbol for name" name)
  (let [name (->str name)
        hash (crypt.djb2 name)]
    (table.insert _G.nyoom/pack (pack (.. :nyoom. hash) {:nyoom-module name}))))

(lambda nyoom-module-p! [name ?config]
  "Checks if a module is enabled. Return config if given, otherwise return
  true or false based on the state of the module
  Accepts the following arguements:
  name -> a symbol.
  config -> (optional) a table
  Example of use:
  ```fennel
  (nyoom-module-p! tree-sitter)
  (if (nyoom-module-p! tree-sitter)
    (do ...))
  ```"
  (assert-compile (sym? name) "expected symbol for name" name)
  (let [name (->str name)
        module-exists (not= nil (. _G.nyoom/modules name))]
    (if (nil? ?config)
        (if module-exists
            `true
            `false)
        (let [config (or ?config)]
          (when module-exists
            `,config)))))

(lambda nyoom-module-ensure! [name]
  "Ensure a module is enabled
  Accepts the following arguements:
  name -> a symbol.
  Example of use:
  ```fennel
  (nyoom-module-ensure! tools.tree-sitter)
  ```"
  (assert-compile (sym? name) "expected symbol for name" name)
  (when (not= nil (. _G.nyoom/modules name))
    (let [msg (.. "One of your installed modules depends on " (->str name)
                  ". Please enable it")]
      `(vim.notify ,msg vim.log.levels.WARN))))

(lambda nyoom-package-count! []
  "Returns code to calculate number of packages at runtime"
  `(length (or _G.nyoom/pack [])))

(lambda nyoom-module-count! []
  "Returns code to calculate number of modules at runtime"
  `(length (or _G.nyoom/modules [])))

(lambda nyoom-spec-count! []
  "Returns code to calculate number of modules at runtime"
  `(length (or _G.nyoom/specs [])))

; (tset _G :nyoom/servers [])
; (tset _G :nyoom/lintesr [])
; (tset _G :nyoom/formatters [])
; (tset _G :nyoom/parsers [])
; (tset _G :nyoom/cmp [])
;;

;; (lambda nyoom-add-language-server! [server ?config]
;;   (assert-compile (sym? server) "expected symbol for server" server)
;;   (let [server (->str server)
;;         config (or ?config)]
;;     (tset _G :nyoom/servers server config)))
;;
;;
;; (lambda nyoom-load-language-servers! []
;;   (let [servers _G.nyoom/servers]
;;     (each [server server_config (pairs servers)]
;;       ((. (. lsp server) :setup) (deep-merge defaults server_config)))))
;;
;; (lambda nyoom-add-linter! [])
;; (lambda nyoom-add-formatter! [])
;; (lambda nyoom-add-parsers! [])
;; (lambda nyoom-add-cmp-source! [])

{: expr->str
 : extend-fn
 : vlua
 : colorscheme
 : sh
 : custom-set-face!
 : set!
 : local-set!
 : map!
 : buf-map!
 : let!
 : command!
 : local-command!
 : autocmd!
 : augroup!
 : clear!
 : pack
 : rock
 : rock!
 : unpack!
 : packadd!
 : pact-use-package!
 : verify-dependencies!
 : lz-package!
 : vim-pack-spec!
 : lz-unpack!
 : lz-trigger-load!
 : lz-load-specs!
 : lz-init-modules!
 : lz-compile-modules!
 : lz-config-modules!
 : fake-module!
 : nyoom!
 : nyoom-module!
 : nyoom-module-p!
 : nyoom-module-ensure!
 : nyoom-package-count!
 : nyoom-module-count!}
