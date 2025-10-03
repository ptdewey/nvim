(import-macros {: pack! : nmap :raw-setup! setup!} :macros)

;; TODO: load on some event (would be nice on creation of a 2nd buffer)
;; - Create custom lze handler to trigger on BufAdd with `#vim.fn.getbufinfo({buflisted = 1}) >= 2`
(pack! [{:src "https://github.com/ahkohd/buffer-sticks.nvim"
         ; "file:///home/patrick/projects/buffer-sticks.nvim"
         :data {:on_require :buffer-sticks
                :after (fn [] (setup! :buffer-sticks {})
                         (. (require :buffer-sticks) :show))}}])

(nmap :<leader>m (fn []
                   ((. (require :buffer-sticks) :jump)))
      {:desc "jump buffers"})

(nmap :<leader>xx (fn []
                    ((. (require :buffer-sticks) :close)))
      {:desc "close buffer"})
