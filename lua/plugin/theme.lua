vim.pack.add({
    { src = "https://github.com/ptdewey/darkearth-nvim" },
    -- { src = "https://github.com/ptdewey/monalisa-nvim" },
    -- { src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
    -- { src = "https://github.com/vague2k/vague.nvim" },
    -- { src = "https://github.com/ptdewey/witchesbrew.nvim" },
    -- { src = "https://github.com/savq/melange-nvim" },
    -- { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
    { src = "https://github.com/everviolet/nvim", name = "evergarden" },
}, { confirm = false })

local p = require("profiler")

p.colorscheme("darkearth")
-- p.colorscheme("lightearth")

-- p.colorscheme("monalisa")
-- p.colorscheme("oxocarbon")
-- p.colorscheme("melange")
-- p.colorscheme("witchesbrew")
-- p.colorscheme("rose-pine")
-- p.colorscheme("rose-pine-dawn")

-- p.require_and_setup("evergarden", {
--     overrides = {
--         ["@type.definition"] = { fg = "#F5D098" },
--     },
-- })
-- p.colorscheme("evergarden")
