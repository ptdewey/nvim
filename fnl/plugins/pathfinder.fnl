(import-macros {: pack! : setup! : nmap} :macros)

(pack! [{:src "https://codeberg.org/pdewey/pathfinder-nvim"
         :data {:keys :<C-n>
                :on_require :pathfinder
                :cmd :Pathfinder
                :after (setup! :pathfinder
                               {:keys {:toggle {:key :<C-n>}}
                                :open_in_current_dir true
                                :style {:show_goto_parent false}})}}])

(nmap :<leader>N
      (fn []
        ((. (require :pathfinder) :toggle) {:open_in_current_dir false}))
      {:desc :Pathfinder})

(nmap :<leader>sp "<cmd>Pathfinder select<CR>" {:desc "Select Path"})
