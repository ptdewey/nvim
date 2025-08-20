local p = require("profiler")

-- NOTE: this should be the default
vim.o.packpath = vim.fs.joinpath(vim.fn.stdpath("data"), "site")

vim.pack.add({
    { src = "https://github.com/vague2k/vague.nvim" },
})

-- p.colorscheme("darkearth")
-- p.colorscheme("monalisa")
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

vim.api.nvim_create_user_command("PackDel", function(args)
    vim.pack.del(args.fargs)
end, { nargs = "+", complete = "packadd" })

vim.api.nvim_create_user_command("PackUpdate", function(args)
    vim.pack.update(args.fargs)
end, { nargs = "*", complete = "packadd" })

-- require("profiler").require_and_setup("tokyonight")
-- p.require_and_setup("tokyonight")
-- p.colorscheme("tokyonight")
