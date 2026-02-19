;; highlight on yank
(import-macros {: autocmd!} :macros)

(let [hg (vim.api.nvim_create_augroup :YankHighlight {:clear true})]
  (autocmd! :TextYankPost {:callback vim.highlight.on_yank
                           :group hg
                           :pattern "*"}))
