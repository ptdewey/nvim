(import-macros {: pack! : spec! : setup!} :macros)

(pack! [(spec! "https://github.com/ptdewey/darkearth-nvim"
               {:colorscheme :darkearth})
        (spec! "https://github.com/nyoom-engineering/oxocarbon.nvim"
               {:colorscheme :oxocarbon})
        ; (spec! "https://github.com/rose-pine/neovim"
        ;        {:name :rose-pine :colorscheme :rose-pine})
        ; (spec! "https://github.com/savq/melange-nvim" {:colorscheme :melange})
        (spec! "https://github.com/everviolet/nvim"
               {:name :evergarden
                :colorscheme :evergarden
                :after (setup! :evergarden
                               {:overrides {"@type.definition" {:fg "#F5D098"}}})})])

(vim.cmd.colorscheme :darkearth)
