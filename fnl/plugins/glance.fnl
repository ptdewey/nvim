(import-macros {: pack! : setup!} :macros)

(pack! "https://github.com/DNLHC/glance.nvim"
  :cmd :Glance
  :after (setup! :glance {}))
