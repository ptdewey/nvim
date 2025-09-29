-- set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Import required plugins (fennel interpreter and lazy loader)
vim.pack.add({
    { src = "https://github.com/rktjmp/hotpot.nvim", version = "v0.14.8" },
    { src = "https://github.com/BirdeeHub/lze" },
}, { confirm = false })

require("hotpot")

-- Can only be loaded after hotpot
require("timer").setup()
require("profiler")

-- Load themes first
require("plugin.theme")

-- load required files
require("config.maps")
require("config.opts")
require("autocmds")

-- Load all files in plugin directories
require("pack")
require("plugin")
require("plugins")
