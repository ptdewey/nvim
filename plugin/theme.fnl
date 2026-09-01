(import-macros {: pack! : spec! : setup!} :macros)

(pack! [(spec! "https://github.com/ptdewey/darkearth-nvim"
               ; (vim.fn.expand :$HOME/projects/darkearth-nvim)
               {:colorscheme [:darkearth :lightearth :earth]})
        (spec! "https://github.com/nyoom-engineering/oxocarbon.nvim"
               {:colorscheme [:oxocarbon]})
        (spec! "https://github.com/catppuccin/nvim.git"
               {:colorscheme [:catppuccin :catppuccin-mocha]})])

; (vim.cmd.colorscheme :darkearth)
(vim.cmd.colorscheme :lightearth)
; (vim.cmd.colorscheme :catppuccin-mocha)
; (vim.cmd.colorscheme :oxocarbon)
