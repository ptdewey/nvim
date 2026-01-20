vim.pack.add({
    { src = "https://github.com/ptdewey/darkearth-nvim" },
    { src = "https://github.com/ptdewey/monalisa-nvim" },
    { src = "https://github.com/vague2k/vague.nvim" },
    { src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
    { src = "https://github.com/ptdewey/witchesbrew.nvim" },
    { src = "https://github.com/ptdewey/vitesse-nvim" },
    { src = "https://github.com/savq/melange-nvim" },
    { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
    { src = "https://github.com/everviolet/nvim" },
}, { confirm = false })

local p = require("profiler")

-- p.require_and_setup("vague", {
--     bold = false,
--     italic = false,
--     on_highlights = function(highlights, colors)
--         highlights["IblIndent"] = { fg = "#27272a" }
--         highlights["DiagnosticHint"] = highlights["fn"]
--         highlights["DiagnosticVirtualTextHint"] = highlights["DiagnosticHint"]
--     end,
-- })

-- TODO: remove bolding from oxocarbon stuff
-- change into lsp highlight color to match comments

-- p.colorscheme("darkearth")
-- p.colorscheme("vague")
-- p.colorscheme("monalisa")
-- p.colorscheme("oxocarbon")
-- p.colorscheme("melange")
-- p.colorscheme("witchesbrew")
-- p.colorscheme("rose-pine")
-- p.colorscheme("rose-pine-dawn")

p.require_and_setup("evergarden", {
    overrides = {
        ["@type.definition"] = { fg = "#F5D098" },
    },
})
p.colorscheme("evergarden")

vim.api.nvim_create_user_command("Colorscheme", function(args)
    p.colorscheme(args.args)
end, { nargs = 1, complete = "color" })
