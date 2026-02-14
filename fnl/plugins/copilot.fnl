(import-macros {: pack! : setup! : nmap} :macros)

(let [opts {:panel {:enabled false}
            :filetypes {:markdown true :typst true :help true}
            :suggestion {:enabled true
                         :keymap {:accept "<C-,>" :dismiss :<C-/>}}}]
  (pack! "https://github.com/zbirenbaum/copilot.lua"
    :cmd :Copilot
    :after (setup! :copilot opts)))

(nmap :<leader>ce "<cmd>Copilot enable<CR>" {:desc "copilot enable"})
(nmap :<leader>cd "<cmd>Copilot disable<CR>" {:desc "copilot disable"})
