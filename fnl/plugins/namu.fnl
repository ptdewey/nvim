(import-macros {: nmap : pack! : setup!} :macros)

(pack! "https://github.com/bassamsdata/namu.nvim"
  :cmd :Namu
  :after (setup! :namu {:namu_symbols {:enable true :options {}}}))

(nmap :<leader>sd "<cmd>Namu symbols<CR>" {:desc "document symbols"})
(nmap :<leader>sw "<cmd>Namu workspace<CR>" {:desc "workspace symbols"})
(nmap :<leader>so "<cmd>Namu watchtower<CR>" {:desc "open symbols"})
