(import-macros {: pack! : setup! : nmap} :macros)

(pack! "https://github.com/NicolasGB/jj.nvim"
  ; :src (vim.fn.expand "file:///$HOME/projects/jj.nvim")
  :cmd [:J :Jdiff]
  :after (setup! :jj {}))

;; TODO: add fzf support
;:picker {:fzf_lua {}
; (nmap :<leader>js (fn []
;                     (let [picker (. (require :jj) picker)]
;                       (picker.status))) {:desc "jj status"})

(nmap :<leader>jd :<cmd>Jdiff<CR> {:desc "jj diff"})
