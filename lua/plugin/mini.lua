return {
    {
        "echasnovski/mini.nvim",
        version = false,

        config = function()
            -- better `a/i` text objects
            require("timer").require_and_setup("mini.ai")
            -- require("mini.ai").setup()
            -- better f/t motions
            require("mini.jump").setup()
            require("mini.icons").setup()
            require("mini.tabline").setup()
            -- LSP notifications
            require("mini.notify").setup()
            require("mini.surround").setup()

            -- Git diff column
            require("mini.diff").setup({
                view = { signs = { add = "+", change = "~", delete = "-" } },
            })

            require("mini.indentscope").setup({
                draw = {
                    delay = 0,
                    animation = require("mini.indentscope").gen_animation.none(),
                },
                symbol = "▏",
                options = { tray_as_border = true },
            })

            -- Startup dashboard
            local starter = require("mini.starter")
            starter.setup({
                items = {
                    starter.sections.recent_files(5, true),
                    {
                        name = "Find Files",
                        action = [[lua require("fzf-lua").files({winopts={preview={horizontal="right:65%",layout="horizontal"}}})]],
                        section = "Quick Actions",
                    },
                    {
                        name = "Directories",
                        action = "Pathfinder select",
                        section = "Quick Actions",
                    },
                    { name = "Lazy", action = "Lazy", section = "Quick Actions" },
                    starter.sections.builtin_actions(),
                },
                footer = "",
                silent = false,
            })

            require("mini.hipatterns").setup({
                highlighters = {
                    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                },
            })

            local miniclue = require("mini.clue")
            miniclue.setup({
                triggers = {
                    { mode = "n", keys = "<Leader>" },
                    { mode = "x", keys = "<Leader>" },
                    { mode = "n", keys = "g" },
                    { mode = "x", keys = "g" },
                    { mode = "n", keys = "'" },
                    { mode = "x", keys = "'" },
                    { mode = "n", keys = '"' },
                    { mode = "x", keys = '"' },
                    { mode = "i", keys = "<C-r>" },
                    { mode = "c", keys = "<C-r>" },
                    { mode = "n", keys = "<C-w>" },
                    { mode = "n", keys = "z" },
                    { mode = "x", keys = "z" },
                },
                clues = {
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),
                },
                window = { delay = 300 },
            })

            -- Mini visits
            require("mini.visits").setup()
            vim.keymap.set("n", "<C-e>", require("mini.visits").select_path, {})
        end,
    },
}
