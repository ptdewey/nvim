local pack = require("config.pack")
pack.add("https://github.com/nvim-mini/mini.nvim")

vim.keymap.set("n", "<leader>ga", "<cmd>Git add %<CR>", { desc = "git add" })
vim.keymap.set("n", "<leader>v", function()
    require("mini.visits").select_path()
end)
vim.keymap.set("n", "<leader>gd", function()
    require("mini.diff").toggle_overlay()
end)

-- vim.keymap.set("n", "-", function()
--     require("mini.files").open()
-- end)

require("lze").load({
    {
        name = "mini.ai",
        event = { "BufReadPost", "BufNewFile" },
        load = function()
            require("mini.ai").setup()
        end,
    },
    {
        name = "mini.jump",
        keys = { "t", "f", "T", "F" },
        load = function()
            require("mini.jump").setup()
        end,
    },
    {
        name = "mini.icons",
        event = "UIEnter",
        load = function()
            require("mini.icons").setup()
        end,
    },
    {
        name = "mini.notify",
        event = "LspAttach",
        load = function()
            require("mini.notify").setup()
        end,
    },
    {
        name = "mini.surround",
        keys = { "S", "sd", "sf", "sF", "sh", "cs", "sn" },
        load = function()
            require("mini.surround").setup({
                mappings = { add = "S", delete = "sd", replace = "cs" },
            })
        end,
    },
    {
        name = "mini.git",
        cmd = "Git",
        keys = { "<leader>ga" },
        load = function()
            require("mini.git").setup()
        end,
    },
    {
        name = "mini.visits",
        event = "BufReadPost",
        load = function()
            require("mini.visits").setup()
        end,
    },
    {
        name = "mini.diff",
        event = "BufReadPost",
        load = function()
            require("mini.diff").setup({
                view = {
                    style = "sign",
                    signs = { add = "+", change = "~", delete = "-" },
                    priority = 49,
                },
            })
        end,
    },
    {
        name = "mini.indentscope",
        event = { "BufReadPost", "BufNewFile" },
        load = function()
            local indentscope = require("mini.indentscope")
            indentscope.setup({
                draw = { delay = 0, animation = indentscope.gen_animation.none() },
                symbol = "▏",
                options = { tray_as_border = true },
            })
        end,
    },
    {
        name = "mini.starter",
        load = function()
            local starter = require("mini.starter")
            starter.setup({
                items = {
                    starter.sections.recent_files(5, true),
                    starter.sections.builtin_actions(),
                },
                footer = "",
                silent = false,
            })
        end,
    },
    {
        name = "mini.hipatterns",
        event = { "BufReadPost", "BufNewFile" },
        load = function()
            local hipatterns = require("mini.hipatterns")
            hipatterns.setup({
                highlighters = { hex_color = hipatterns.gen_highlighter.hex_color() },
            })
        end,
    },
    {
        name = "mini.clue",
        keys = {
            "<Leader>",
            "g",
            "'",
            '"',
            "[",
            "]",
            "<C-w>",
            "z",
            { "<C-r>", mode = { "i", "c" } },
        },
        load = function()
            local clue = require("mini.clue")
            clue.setup({
                triggers = {
                    { mode = "n", keys = "<Leader>" },
                    { mode = "x", keys = "<Leader>" },
                    { mode = "n", keys = "g" },
                    { mode = "x", keys = "g" },
                    { mode = "n", keys = "'" },
                    { mode = "x", keys = "'" },
                    { mode = "n", keys = "[" },
                    { mode = "n", keys = "]" },
                    { mode = "n", keys = '"' },
                    { mode = "x", keys = '"' },
                    { mode = "i", keys = "<C-r>" },
                    { mode = "c", keys = "<C-r>" },
                    { mode = "n", keys = "<C-w>" },
                    { mode = "n", keys = "z" },
                    { mode = "x", keys = "z" },
                },
                clues = {
                    clue.gen_clues.g(),
                    clue.gen_clues.square_brackets(),
                    clue.gen_clues.marks(),
                    clue.gen_clues.registers(),
                    clue.gen_clues.windows(),
                    clue.gen_clues.z(),
                },
                window = { delay = 300 },
            })
        end,
    },
    -- {
    --     name = "mini.files",
    --     event = "UIEnter",
    --     load = function()
    --         require("mini.files").setup({
    --             mappings = { go_out_plus = "-", go_in_plus = "<CR>" },
    --         })
    --     end,
    -- },
    {
        name = "mini.cmdline",
        event = "CmdlineEnter",
        load = function()
            require("mini.cmdline").setup({
                autocomplete = { enable = true },
                autopeek = { enable = true },
            })
        end,
    },
})
