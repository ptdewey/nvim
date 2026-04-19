(import-macros {: pack! : setup! : nmap} :macros)

(pack! "https://github.com/carderne/pi-nvim.git"
       {:after (setup! :pi-nvim {})
        :cmd [:Pi
              :PiSend
              :PiSendFile
              :PiSendSelection
              :PiSendBuffer
              :PiPing
              :PiSessions]})
