vim.pack.add({
    { src = "https://github.com/ptdewey/darkearth-nvim" },
    { src = "https://github.com/ptdewey/monalisa-nvim" },
    { src = "https://github.com/vague2k/vague.nvim" },
})

local p = require("profiler")

p.require_and_setup("vague", {
    bold = false,
    italic = false,
    on_highlights = function(highlights, colors)
        highlights["IblIndent"] = { fg = "#27272a" }
        highlights["DiagnosticHint"] = highlights["Comment"]
        highlights["DiagnosticVirtualTextHint"] = highlights["DiagnosticHint"]
    end,
})

p.colorscheme("vague")
-- p.colorscheme("monalisa")
-- p.colorscheme("darkearth")
