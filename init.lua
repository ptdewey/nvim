-- set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Fix pack_path issues
-- vim.env.NVIM_APPNAME = vim.env.NVIM_APPNAME or 'nvim'
-- local pack_path = vim.fn.expand('$XDG_DATA_HOME/$NVIM_APPNAME/site')
-- vim.o.packpath = vim.o.packpath ..',' .. pack_path

-- TODO: figure out how to get paths from this
vim.pack.add({
    { src = "https://github.com/rktjmp/hotpot.nvim", version = "v0.14.8" },
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

vim.api.nvim_create_user_command("PackDel", function(args)
    vim.pack.del(args.fargs)
end, { nargs = "+", complete = "packadd" })

vim.api.nvim_create_user_command("PackUpdate", function(args)
    -- TODO: update all if no args are passed?
    vim.pack.update(args.fargs)
end, { nargs = "*", complete = "packadd" })

-- Load all files in plugin dir (TODO: maybe not desirable?)
require("plugin")
require("plugins")
