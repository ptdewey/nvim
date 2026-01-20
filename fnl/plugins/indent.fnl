(import-macros {: pack! : setup!} :macros)

(pack! [{:src "https://github.com/saghen/blink.indent"
         :data {:event [:BufReadPost :BufNewFile :BufEnter]
                :after (setup! :blink.indent
                               {:blocked {:filetypes [:fennel]}
                                :static {:char "▏"}
                                :scope {:enabled false}})}}])
