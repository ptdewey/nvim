(import-macros {: pack! : spec! : setup!} :macros)

(pack! [(spec! ;"https://github.com/ptdewey/darkearth-nvim"
               (vim.fn.expand :$HOME/projects/darkearth-nvim)
               {:colorscheme [:darkearth :lightearth :earth]})
        ; (spec! "https://github.com/nyoom-engineering/oxocarbon.nvim"
        ;        {:colorscheme :oxocarbon})
        ; (spec! "https://github.com/savq/melange-nvim" {:colorscheme :melange})
        (spec! "https://github.com/rose-pine/neovim"
               {:name :rose-pine :colorscheme [:rose-pine :rose-pine-main]})])

; (vim.cmd.colorscheme :rose-pine)
(vim.cmd.colorscheme :darkearth)
; (vim.cmd.colorscheme :lightearth)
