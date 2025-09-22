(import-macros {: pack!} :macros)

(pack! [{:src "https://github.com/windwp/nvim-autopairs"}])

(let [p (require :profiler)]
  (p.require_and_setup :nvim-autopairs))
