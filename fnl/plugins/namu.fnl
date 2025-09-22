(import-macros {: nmap : cmd! : pack!} :macros)

(pack! ["https://github.com/bassamsdata/namu.nvim"])

(cmd! :Namu (fn [args]
              (let [p (require :profiler)]
                (p.require_and_setup :namu
                                     {:namu_symbols {:enable true :options {}}
                                      :namu_symbols {:enable true :options {}}}))
              (vim.cmd (.. :Namu args.args))) {:nargs "?"})

(nmap :<leader>sd "<cmd>Namu symbols<CR>" {:desc "document symbols"})
(nmap :<leader>sw "<cmd>Namu workspace<CR>" {:desc "workspace symbols"})
(nmap :<leader>so "<cmd>Namu watchtower<CR>" {:desc "open symbols"})
