vim.pack.add({
    { src = "https://github.com/ptdewey/darkearth-nvim" },
    { src = "https://github.com/ptdewey/monalisa-nvim" },
    { src = "https://github.com/vague2k/vague.nvim" },
    { src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
    { src = "https://github.com/ptdewey/witchesbrew.nvim" },
    { src = "https://web.solanaceae.net/sol/vitesse-nvim" },
})

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

-- p.colorscheme("vague")
-- p.colorscheme("monalisa")
-- p.colorscheme("darkearth")
p.colorscheme("oxocarbon")
-- p.colorscheme("witchesbrew")
-- p.colorscheme("vitesse")

vim.api.nvim_create_user_command("Colorscheme", function(args)
    p.colorscheme(args.args)
end, { nargs = 1, complete = "color" })
