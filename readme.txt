* Install
  To install the configuration, run:

  git clone https://github.com/boydkelly/nyoom.nvim ~/.config/nvim-nyoom
  export NVIM_APPNAME="nvim-nyoom"
  nvim

  Running `bin/nyoom install` also works and forces `NVIM_APPNAME` to `nvim-nyoom`.
  Running `bin/nyoom sync` will also preinstall treesitter parsers and lsp tools.

  Mason works too but for whatever reason it wants to reinstall every time you open it.

* Notes
  ** New Layers
  Updated/added: cmp, blink, none-ls, conform (format), javascript, ts, svelte, oil.
  Updated to 2026 configs: tree-sitter, lsp, etc.

  ** Engine Changes
  - Replaced packer with `vim.pack` and {https://github.com/lumen-oss/lz.n}[lz.n]
  - Replaced hotpot with {https://github.com/udayvir-singh/tangerine.nvim}[tangerine.nvim]

  The `use-package!` macro has been replaced with `lz-package!`.
  It follows the same spirit but requires minor syntax changes in `init.fnl` files.

* lz.n spec properties
  - `after`
  - `before`
  - `beforeAll`
  - `enabled`
  - `event`
  - `ft`
  - `lazy`
  - `priority` (Only works with plugins in `start/`, not `opt/`)
  - `cmd`
  - `colorscheme`
  - `keys`
  > {https://github.com/neovim/neovim/issues/35550}[Issue #35550] currently breaks `keys` for lazy loading.
  > I've moved keymaps into `config` and used `event` triggers as a workaround.

* Nyoom keys
  - `nyoom-module`: Requires config; inserts to `lz.n` `after` function.
  - `run` / `build-file`: Creates `beforeAll` function for binaries (fzf, blink, etc).
  - `call-setup`: Runs naked setup (kinda like legacy Nyoom).
  - `requires`: Adds to `vim.pack` for installation and adds `trigger_load` to `after`.
  - `defer`: Maps to `:event :DeferredUIEnter`.

_I'm just a self-taught hacker. Proceed with caution! This is nowhere near cooked._
