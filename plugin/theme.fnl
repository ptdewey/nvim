(import-macros {: pack! : spec! : setup!} :macros)

(pack! [(spec! ;"https://github.com/ptdewey/darkearth-nvim"
               (vim.fn.expand :$HOME/projects/darkearth-nvim)
               {:colorscheme [:darkearth :lightearth :earth]})])

(vim.cmd.colorscheme :darkearth)
; (vim.cmd.colorscheme :lightearth)
