return {
    {
        "https://codeberg.org/pdewey/pathfinder-nvim",
        -- dir = "~/projects/pathfinder-nvim/",
        keys = {
            { "<leader>N", desc = "Pathfinder" },
            { "<C-n>", desc = "Pathfinder" },
            { "<leader>sd", desc = "[S]earch [D]irectories" },
        },
        cmd = { "Pathfinder" },
        config = function()
            require("pathfinder").setup({
                keys = { toggle = { key = "<C-n>" } },
                open_in_current_dir = true,
                style = { show_goto_parent = false },
            })

            vim.keymap.set("n", "<leader>N", function()
                require("pathfinder").toggle({ open_in_current_dir = false })
            end, { desc = "Pathfinder" })

            vim.keymap.set(
                "n",
                "<leader>sd",
                require("pathfinder").select_directory,
                { silent = true }
            )
        end,
    },

    {
        "https://codeberg.org/pdewey/deez-nvim",
        -- branch = "feat-explorer",
        -- dir = "~/projects/deez-nvim/",

        keys = {
            { "<leader>gb", desc = "[G]it [B]rowse" },
            { "<leader>tf", desc = "Open Al[T]ernate [F]ile" },
            { mode = "x", "<leader>wc", desc = "[W]ord [C]ount" },
        },
        cmd = { "GitBrowse", "RenameFile", "AltFile" },

        config = function()
            require("deez.gitbrowse").setup({})
            require("deez.altfile").setup({})
            require("deez.wordcount").setup({})
            require("deez.rename").setup({})

            vim.keymap.set("n", "<leader>gb", function()
                require("deez.gitbrowse").open()
            end, { desc = "Open current Git repository in browser" })

            vim.keymap.set("n", "<leader>tf", function()
                require("deez.altfile").open()
            end, { desc = "Open alternate file" })

            vim.api.nvim_create_user_command("GitBrowse", function()
                require("deez.gitbrowse").open()
            end, { desc = "Open current Git repository in browser" })
        end,
    },
}
