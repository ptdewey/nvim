(import-macros {: pack! : setup!} :macros)

(pack! [{:src "https://github.com/MagicDuck/grug-far.nvim"
         :data {:on_require :grug-far
                :cmd [:GrugFar :GrugFarWithin]
                :after (setup! :grug-far {})}}])
