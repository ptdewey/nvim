(import-macros {: pack! : setup!} :macros)

(pack! "https://github.com/gpanders/nvim-parinfer"
       {:version :lua-plugin :ft :fennel :after (setup! :parinfer)})
