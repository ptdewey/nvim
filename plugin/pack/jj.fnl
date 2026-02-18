(import-macros {: pack! : spec! : setup! : nmap} :macros)

(pack! [(spec! "https://github.com/NicolasGB/jj.nvim"
               {:cmd [:J :Jdiff] :after (setup! :jj)})
        (spec! "https://github.com/rafikdraoui/jj-diffconflicts"
               {:cmd :JJDiffConflicts})])

(nmap :<leader>jd :<cmd>Jdiff<CR> {:desc "jj diff"})
(nmap :<leader>jr :<cmd>JJDiffConflicts {:desc "jj resolve"})
