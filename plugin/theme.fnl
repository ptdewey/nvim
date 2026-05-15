(import-macros {: pack! : spec! : setup!} :macros)

(pack! [(spec! "https://github.com/ptdewey/darkearth-nvim"
               {:colorscheme :darkearth})
        ; (spec! "https://github.com/nyoom-engineering/oxocarbon.nvim"
        ;        {:colorscheme :oxocarbon})
        ; (spec! "https://github.com/rose-pine/neovim"
        ;        {:name :rose-pine :colorscheme :rose-pine})
        ; (spec! "https://github.com/savq/melange-nvim" {:colorscheme :melange})
        (spec! "https://github.com/zenbones-theme/zenbones.nvim"
               {:colorscheme [:zenbones
                              :rosebones
                              :forestbones
                              :nordbones
                              :kanagawabones]
                :before #(set vim.g.zenbones_compat 1)})])

; (vim.cmd.colorscheme :darkearth)
(vim.cmd.colorscheme :lightearth)
