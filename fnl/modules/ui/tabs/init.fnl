(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :akinsho/bufferline.nvim {:nyoom-module ui.tabs :opt true})

; (lz-package! :akinsho/bufferline.nvim
;               {:nyoom-module ui.tabs
;                :opt true
;                :setup (fn [
;                                        (vim.api.nvim_create_autocmd [:BufAdd :TabEnter]
;                                                                     {:pattern "*"
;                                                                      :group (vim.api.nvim_create_augroup :BufferLineLazyLoading
;                                                                                                          {})
;                                                                      :callback (fn []
;                                                                                  (local count
;                                                                                         (length (vim.fn.getbufinfo {:buflisted 1})))
;                                                                                  (when (>= count
;                                                                                            2)
;                                                                                    ((. (require :packer)
;                                                                                        :loader) :bufferline.nvim)))})])})

