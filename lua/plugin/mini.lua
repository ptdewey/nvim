vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

local p = require("profiler")

require("lze").load({
    -- {
    --     -- better `a/i` text objects
    --     "mini.ai",
    --     event = { "BufReadPost", "BufNewFile" },
    --     load = function()
    --         p.require("mini.ai")
    --     end,
    -- },
    -- {
    --     -- better f/t motions
    --     "mini.jump",
    --     keys = { "t", "f", "T", "F" },
    --     load = function()
    --         p.require("mini.jump")
    --     end,
    -- },
    {
        "mini.icons",
        dep_of = "mini.tabline", -- FIX: tabline doesn't load icons unless this is specified
        load = function()
            p.require("mini.icons")
        end,
    },
    {
        "mini.tabline",
        event = { "BufReadPost", "BufNewFile" },
        load = function()
            p.require("mini.tabline")
        end,
    },
    {
        "mini.notify",
        event = "LspAttach",
        load = function()
            p.require("mini.notify")
        end,
    },
    {
        "mini.surround",
        keys = { "sa", "sd", "sf", "sF", "sh", "sr", "sn" },
        load = function()
            p.require("mini.surround")
        end,
    },
    {
        "mini.visits",
        keys = { "<C-e>" },
        load = function()
            p.require("mini.visits")
            vim.keymap.set("n", "<C-e>", require("mini.visits").select_path, {})
        end,
    },
    {
        "mini.diff",
        event = { "BufReadPost" },
        load = function()
            p.require_and_setup("mini.diff", {
                view = {
                    style = "sign",
                    signs = { add = "+", change = "~", delete = "-" },
                    priority = 49,
                },
            })
        end,
    },
    {
        "mini.indentscope",
        event = { "BufReadPost", "BufNewFile" },
        load = function()
            p.require_and_setup("mini.indentscope", {
                draw = {
                    delay = 0,
                    animation = require("mini.indentscope").gen_animation.none(),
                },
                symbol = "▏",
                options = { tray_as_border = true },
            })
        end,
    },
    {
        "mini.starter",
        event = "VimEnter",
        load = function()
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
                    starter.sections.builtin_actions(),
                },
                footer = "",
                silent = false,
            })
        end,
    },
    {
        "mini.hipatterns",
        event = { "BufReadPost", "BufNewFile" },
        load = function()
            p.require_and_setup("mini.hipatterns", {
                highlighters = {
                    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                },
            })
        end,
    },
    {
        "mini.clue",
        keys = { "<Leader>", "g", "'", '"', "<C-w>", "z", { "<C-r>", mode = { "i", "c" } } },
        load = function()
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
        end,
    },
})
