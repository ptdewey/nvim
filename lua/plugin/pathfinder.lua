vim.pack.add({
    {
        src = "https://codeberg.org/pdewey/pathfinder-nvim",
        data = {
            keys = "<C-n>",
            cmd = "Pathfinder",
            after = function()
                require("profiler").require_and_setup("pathfinder", {
                    keys = { toggle = { key = "<C-n>" } },
                    open_in_current_dir = true,
                    style = { show_goto_parent = false },
                })

                vim.keymap.set("n", "<leader>N", function()
                    require("pathfinder").toggle({ open_in_current_dir = false })
                end, { desc = "Pathfinder" })

                vim.keymap.set("n", "<leader>sp", function()
                    require("pathfinder").select_directory()
                end, { silent = true })
            end,
        },
    },
}, require("pack").opts)
