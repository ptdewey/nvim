(import-macros {: pack! : setup!} :macros)

(let [opts {:blocked {:filetypes [:fennel]}
            :static {:char "▏"}
            :scope {:enabled false}}]
  (pack! "https://github.com/saghen/blink.indent"
         {:event [:BufReadPost :BufNewFile :BufEnter]
          :after (setup! :blink.indent opts)}))
