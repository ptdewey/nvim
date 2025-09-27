(import-macros {: nmap : cmd! : pack!} :macros)

(local opts {:namu_symbols {:enable true :options {}}})

(local c (fn []
           (cmd! :Namu (fn [args]
                         (let [p (require :profiler)]
                           (p.require_and_setup :namu opts))
                         (vim.cmd (.. :Namu args.args)))
                 {:nargs "?"})))

(pack! [{:src "https://github.com/bassamsdata/namu.nvim"
         :data {:cmd :Namu :after c}}])

(nmap :<leader>sd "<cmd>Namu symbols<CR>" {:desc "document symbols"})
(nmap :<leader>sw "<cmd>Namu workspace<CR>" {:desc "workspace symbols"})
(nmap :<leader>so "<cmd>Namu watchtower<CR>" {:desc "open symbols"})
