(import-macros {: pack! : setup! : nmap} :macros)

(pack! [{:src "https://github.com/MagicDuck/grug-far.nvim"
         :data {:on_require :grug-far
                :cmd [:GrugFar :GrugFarWithin]
                :after (setup! :grug-far {})}}])

(nmap :<leader>gf :<cmd>GrugFar<CR> {:desc :grug-far})
(nmap :<leader>gw :<cmd>GrugFarWithin<CR> {:desc "grug-far within"})
