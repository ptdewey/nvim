(import-macros {: pack! : setup!} :macros)

(pack! "https://github.com/ptdewey/gokit-nvim" {:ft :go :after (setup! :gokit)})
