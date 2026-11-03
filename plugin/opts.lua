-- Core options.
vim.o.number = true
vim.o.rnu = true
vim.o.autoindent = true
vim.o.scrolloff = 8
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.showcmd = true
vim.o.mouse = "a"
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.breakindent = true

-- searching
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
-- decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300
-- aesthetics
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
-- vim.o.winborder = "rounded"
-- vim.o.winborder = "bold"

-- swap/undo
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("state") .. "/undo"
-- spellcheck
vim.o.spell = true
vim.o.spelllang = "en_us"
vim.o.spellfile = vim.fn.expand("$HOME/.config/nvim/spell/en.utf-8.add")
-- completion
vim.o.completeopt = "menuone,noselect"
-- Popup menu settings
vim.o.wildmenu = true
vim.o.wildmode = "noselect,full"
vim.o.wildoptions = "pum,fuzzy"
vim.o.pumheight = 15
-- system settings
vim.o.clipboard = "unnamedplus"
vim.o.fileformats = "unix,dos"

-- globals
vim.g.netrw_banner = 0
vim.g.netrw_hide = 1
vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro"
vim.g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

-- Experimental v2 command/message UI.
require("vim._core.ui2").enable({ enable = true, msg = { target = "cmd" } })

-- lsp diagnostics config
-- TODO: move this to a new file with lsp autocmds (and lsp plugins?)
vim.diagnostic.config({
    -- virtual_lines = true,
    virtual_text = true,
    -- update_in_insert = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
    },
})
