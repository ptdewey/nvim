vim.pack.add({
    { src = "https://github.com/echasnovski/mini.nvim" },
})

local p = require("profiler")

-- better `a/i` text objects
p.require("mini.ai")
-- require("mini.ai").setup()
-- better f/t motions
p.require("mini.jump")
p.require("mini.icons")
p.require("mini.tabline")
-- LSP notifications
p.require("mini.notify")
p.require("mini.surround")

-- Mini visits
p.require("mini.visits")
vim.keymap.set("n", "<C-e>", require("mini.visits").select_path, {})

-- Git sign column
p.require_and_setup("mini.diff", {
    view = {
        style = "sign",
        signs = { add = "+", change = "~", delete = "-" },
    },
})

p.require_and_setup("mini.indentscope", {
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
        starter.sections.builtin_actions(),
    },
    footer = "",
    silent = false,
})

p.require_and_setup("mini.hipatterns", {
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
