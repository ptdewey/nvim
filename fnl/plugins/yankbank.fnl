(import-macros {: pack! : setup! : nmap} :macros)

(pack! [{:src "https://github.com/ptdewey/sqlite.lua"
         :data {:dep_of :yankbank-nvim}}
        {:src "https://github.com/ptdewey/yankbank-nvim"
         :data {:event :VimEnter
                :after (setup! :yankbank
                               {:sep "------"
                                :max_entries 9
                                :num_behavior :jump
                                :focus_gain_poll true
                                :keymaps {}
                                :persist_type :sqlite
                                :debug true
                                :bind_indices :<leader>y})}}])

(let [os-name (: (. (vim.uv.os_uname) :sysname) :lower)]
  (if (= os-name :linux)
      (set vim.g.sqlite_clib_path
           :/run/current-system/sw/share/nix-ld/lib/libsqlite3.so)))

(nmap :<leader>p :<cmd>YankBank<CR> {:noremap true :desc :yankbank})
