(import-macros {: pack! : spec!} :macros)

(pack! [(spec! (vim.fn.expand "https://github.com/ptdewey/slides-nvim")
               {:cmd :SlidesStart})])
