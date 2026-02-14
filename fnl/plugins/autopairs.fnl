(import-macros {: pack! : setup!} :macros)

(pack! "https://github.com/windwp/nvim-autopairs"
  :event :InsertEnter
  :after (setup! :nvim-autopairs))
