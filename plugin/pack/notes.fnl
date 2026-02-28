(import-macros {: pack! : spec! : setup!} :macros)

(pack! [(spec! (vim.fn.expand "file:///$HOME/projects/nt")
               {:cmd :Nt :after (setup! :nt {})})
        (spec! ;;"https://github.com/ptdewey/slides-nvim" 
               (vim.fn.expand "file://$HOME/projects/scratchpad/slides-nvim")
               {:cmd :SlidesStart})])
