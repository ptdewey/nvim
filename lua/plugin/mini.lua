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
            require("mini.jump2d").setup()
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
                    starter.sections.recent_files(5, true),
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
            local get_root = function()
                return vim.fs.root(0, ".git") or vim.fn.getcwd()
            end

            local open_index = function(i, cwd)
                local pins =
                    require("mini.visits").list_paths(cwd or get_root(), { filter = "pin" })
                if #pins >= i then
                    vim.cmd("edit " .. pins[i])
                else
                    print("mini.visits: no pin with index '" .. i .. "'")
                end
            end

            vim.keymap.set("n", "<leader>a", function()
                local path = vim.fn.expand("%:p")
                if path == "" then
                    return
                end
                local pins = require("mini.visits").list_paths(get_root(), { filter = "pin" })
                for _, pin in ipairs(pins) do
                    if pin == path then
                        require("mini.visits").remove_label("pin", path)
                        return
                    end
                end
                require("mini.visits").add_label("pin", path, get_root())
            end, { desc = "[A]dd visit" })

            for i, key in ipairs({ "<C-h>", "<C-j>" }) do
                vim.keymap.set("n", key, function()
                    open_index(i)
                end, {})
            end

            vim.keymap.set("n", "<C-e>", require("mini.visits").select_path, {})

            vim.keymap.set("n", "<leader>vp", function()
                require("mini.visits").select_path(get_root(), { filter = "pin" })
            end, {})
        end,
    },
}
