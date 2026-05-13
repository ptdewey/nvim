(import-macros {: pack! : setup! : nmap : vmap} :macros)

(pack! "https://github.com/ptdewey/pi-nvim.git"
       ; (vim.fn.expand :$HOME/projects/pi-nvim)
       {:after (setup! :pi-nvim {})
        :cmd [:Pi :PiOpen :PiSendFile :PiSendBuffer :PiPing :PiSessions]})

(nmap :<leader>ap :Pi)
(vmap :<leader>ap :Pi)
