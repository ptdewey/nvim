(import-macros {: pack!} :macros)

(pack! [{:src "https://github.com/windwp/nvim-autopairs"
         :data {:event :InsertEnter
                :after (fn []
                         (let [p (require :profiler)]
                           (p.require_and_setup :nvim-autopairs)))}}]
       {:load (fn [p]
                (let [spec (or p.spec.data {})]
                  (set spec.name p.spec.name)
                  ((. (require :lze) :load) spec)))
        :confirm false})
