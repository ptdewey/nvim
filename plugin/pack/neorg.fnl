(import-macros {: pack! : spec! : raw-setup!} :macros)

(pack! [(spec! "https://github.com/nvim-neorg/neorg"
               {:ft :norg
                :after (fn []
                         (raw-setup! :neorg
                                     {:load {:core.defaults {}
                                             :core.concealer {}
                                             :core.summary {}
                                             :core.journal {}
                                             :core.ui.calendar {}
                                             :core.dirman {:config {:workspaces {:notes "~/Documents/notebook/"}}}}})
                         (vim.schedule #(vim.cmd "doautocmd BufEnter")))})
        (spec! "https://github.com/nvim-lua/plenary.nvim" {:dep_of :neorg})
        (spec! "https://github.com/nvim-neorg/lua-utils.nvim" {:dep_of :neorg})
        (spec! "https://github.com/pysan3/pathlib.nvim" {:dep_of :neorg})
        (spec! "https://github.com/MunifTanjim/nui.nvim" {:dep_of :neorg})
        (spec! "https://github.com/nvim-neotest/nvim-nio" {:dep_of :neorg})])
