(import-macros {: pack! : setup!} :macros)

(let [opts {:blocked {:filetypes [:fennel]}
            :static {:char "▏"}
            :scope {:enabled false}}]
  (pack! [{:src "https://github.com/saghen/blink.indent"
           :data {:event [:BufReadPost :BufNewFile :BufEnter]
                  :after (setup! :blink.indent opts)}}]))
