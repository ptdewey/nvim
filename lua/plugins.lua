local p = require("profiler")

-- NOTE: this should be the default
vim.o.packpath = vim.fs.joinpath(vim.fn.stdpath("data"), "site")

vim.pack.add({
    { src = "https://github.com/vague2k/vague.nvim" },
    -- { src = vim.fn.expand("file:///$HOME/projects/pendulum-nvim.git/v2"), name = "pendulum" },
    -- { src = vim.fn.expand("file:///$HOME/projects/darkearth-nvim") },
    -- { src = vim.fn.expand("https://github.com/ptdewey/darkearth-nvim") },
    -- { src = "https://github.com/ptdewey/pendulum-nvim", branch = "v2" },
})

-- p.colorscheme("darkearth")
p.colorscheme("monalisa")
-- p.require_and_setup("vague", { bold = false, italic = false })
-- p.colorscheme("vague")

vim.api.nvim_create_user_command("PackDel", function(args)
    vim.pack.del({ args.args })
end, { nargs = 1 })

-- require("profiler").require_and_setup("tokyonight")
-- p.require_and_setup("tokyonight")
-- p.colorscheme("tokyonight")
