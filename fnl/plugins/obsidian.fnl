(import-macros {: pack! : setup! : nmap} :macros)

(let [opts {:legacy_commands false
            :workspaces [{:name :notes :path "~/notes"}]
            :notes_subdir :notes
            :daily_notes {:folder :notes/daily :default_tags [:daily]}
            :completion {:nvim_cmp false :blink true :min_chars 2}
            :new_notes_location :notes_subdir
            :picker {:name :fzf-lua}
            :ui {:enable false}
            :templates {:folder :templates}}]
  (pack! "https://github.com/obsidian-nvim/obsidian.nvim" :cmd :Obsidian :ft
         :markdown :after (setup! :obsidian opts)))

(nmap :<leader>nd "<cmd>Obsidian dailies<CR>" {:desc "obsidian dailies"})
(nmap :<leader>no :<cmd>Obsidian<CR> {:desc :obsidian})
(nmap :<leader>nt "<cmd>Obsidian today<CR>" {:desc "daily note"})
(nmap :<leader>nb "<cmd>Obsidian backlinks<CR>" {:desc :backlinks})
