(import-macros {: pack! : setup!} :macros)

(pack! [{:src "https://github.com/gpanders/nvim-parinfer"
         :version :lua-plugin
         :data {:ft :fennel :after (setup! :parinfer)}}])
