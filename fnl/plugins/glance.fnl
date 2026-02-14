(import-macros {: pack! : setup!} :macros)

(pack! [{:src "https://github.com/DNLHC/glance.nvim"
         :data {:cmd :Glance :after (setup! :glance {})}}])
