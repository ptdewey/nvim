(import-macros {: pack! : spec! : setup! : nmap} :macros)

(pack! [(spec! ;; "https://github.com/NicolasGB/jj.nvim"
               "https://github.com/ptdewey/jj.nvim"
               ; (vim.fn.expand :$HOME/projects/oss/jj.nvim)
               {:cmd [:J :Jdiff :Jbrowse]
                :on_require :jj
                :after (setup! :jj {:cmd {:keymaps {:log {:abandon nil}}}})})
        (spec! ;;"https://github.com/rafikdraoui/jj-diffconflicts"
               "https://github.com/ptdewey/jj-diffconflicts"
               {:cmd :JJDiffConflicts})])

; TODO: use the api instead of commands, clean up require call
; (let [jj (require :jj)])
(nmap :<leader>jd :<cmd>Jdiff<CR> {:desc "jj diff"})
(nmap :<leader>jr :<cmd>JJDiffConflicts {:desc "jj resolve"})
(nmap :<leader>ja #((. (require :jj.annotate) :virtual)) {:desc "jj blame"})
(nmap :<leader>l #((. (require :jj.annotate) :line)) {:desc "blame line"})
(nmap :<leader>jb :<cmd>Jbrowse<CR> {:desc "browse current branch"})
(nmap :<leader>jm "<cmd>Jbrowse trunk()<CR>" {:desc "browse default branch"})
