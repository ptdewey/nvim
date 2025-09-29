(import-macros {: pack! : nmap} :macros)

(pack! [{:src "https://github.com/mbbill/undotree"
         :data {:keys :<leader>ut
                :after (fn []
                         (nmap :<leader>ut :<cmd>UndotreeToggle<CR>
                               {:desc "undotree toggle"}))}}])
