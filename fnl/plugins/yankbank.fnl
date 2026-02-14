(import-macros {: pack! : spec! : setup! : nmap} :macros)

(let [opts {:sep "------"
            :max_entries 9
            :num_behavior :jump
            :focus_gain_poll true
            :keymaps {}
            :persist_type :sqlite
            :debug true
            :bind_indices :<leader>y}]
  (pack! [(spec! "https://github.com/ptdewey/sqlite.lua"
            :dep_of :yankbank-nvim)
          (spec! "https://github.com/ptdewey/yankbank-nvim"
            :version :main
            :event :VimEnter
            :after (setup! :yankbank opts))]))

(let [os-name (: (. (vim.uv.os_uname) :sysname) :lower)]
  ;; TODO: find a way of distinguishing nixos systems from other linux
  (if (= os-name :linux)
      (set vim.g.sqlite_clib_path
           :/run/current-system/sw/share/nix-ld/lib/libsqlite3.so)))

(nmap :<leader>p :<cmd>YankBank<CR> {:noremap true :desc :yankbank})
