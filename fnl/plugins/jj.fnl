(import-macros {: pack! : setup! : nmap} :macros)

(pack! [{:src "https://github.com/NicolasGB/jj.nvim"
         :data {:cmd :J :after (setup! :jj {})}}])

;; TODO: add fzf support
;:picker {:fzf_lua {}
; (nmap :<leader>js (fn []
;                     (let [picker (. (require :jj) picker)]
;                       (picker.status))) {:desc "jj status"})
