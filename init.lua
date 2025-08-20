-- set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure lazy and hotpot are always installed
-- local function ensure_installed(plugin, branch)
--     local user, repo = string.match(plugin, "(.+)/(.+)")
--     local repo_path = vim.fn.stdpath("data") .. "/lazy/" .. repo
--     if not (vim.uv or vim.loop).fs_stat(repo_path) then
--         vim.notify("Installing " .. plugin .. " " .. branch)
--         local repo_url = "https://github.com/" .. plugin .. ".git"
--         local out = vim.fn.system({
--             "git",
--             "clone",
--             "--filter=blob:none",
--             "--branch=" .. branch,
--             repo_url,
--             repo_path,
--         })
--         if vim.v.shell_error ~= 0 then
--             vim.api.nvim_echo({
--                 { "Failed to clone " .. plugin .. ":\n", "ErrorMsg" },
--                 { out, "WarningMsg" },
--                 { "\nPress any key to exit..." },
--             }, true, {})
--             vim.fn.getchar()
--             os.exit(1)
--         end
--     end
--     return repo_path
-- end

-- TODO: figure out how to get paths from this
-- vim.o.packpath = vim.fs.joinpath(vim.fn.stdpath("data"), "site")
vim.pack.add({
    { src = "https://github.com/folke/lazy.nvim", version = "stable" },
    { src = "https://github.com/rktjmp/hotpot.nvim", version = "v0.14.8" },
})

-- local lazy_path = ensure_installed("folke/lazy.nvim", "stable")
-- local hotpot_path = ensure_installed("rktjmp/hotpot.nvim", "v0.14.8")

-- As per Lazy's install instructions, but also include hotpot
-- vim.opt.runtimepath:prepend({ hotpot_path, lazy_path })

-- You must call vim.loader.enable() before requiring hotpot unless you are
-- passing {performance = {cache = false}} to Lazy.
vim.loader.enable()
require("hotpot")

require("timer").setup()

-- load plugins outlined in 'plugin' directory with lazy
local plugins = {
    { "rktjmp/hotpot.nvim" },
    { import = "plugin" },
}
require("lazy").setup(plugins, {
    ui = { border = "rounded" },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "zipPlugin",
                "tutor",
                "man",
                "rplugin",
            },
        },
    },
})

-- load required files
require("config.maps")
require("config.options")
require("autocmds")

require("config.opts")

require("plugins")
