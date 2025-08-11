-- theme options
vim.cmd.colorscheme("darkearth")
-- vim.cmd.colorscheme("monalisa")
local options = {
    number = true,
    rnu = true,
    autoindent = true,
    scrolloff = 8,
    splitright = true,
    splitbelow = true,
    showcmd = true,
    mouse = "a",

    -- system specific things
    fileformats = "unix,dos",

    -- tabs
    shiftwidth = 4,
    tabstop = 4,
    expandtab = true,
    smarttab = true,

    -- Sync clipboard between OS and Neovim.
    clipboard = "unnamedplus",

    -- searching
    incsearch = true,
    ignorecase = true,
    smartcase = true,

    -- keep undo file
    undofile = true,

    -- decrease update time
    updatetime = 250,
    timeoutlen = 300,

    -- better completion
    completeopt = "menuone,noselect",

    -- break indent
    breakindent = true,

    -- dictionary file
    spell = true,
    spelllang = "en_us",
    spellfile = vim.fn.expand("$HOME/.config/nvim/spell/en.utf-8.add"),

    -- aesthetics
    termguicolors = true,
    signcolumn = "auto", -- alterntive: "auto, number, yes"
    background = "dark", -- alternative: "light"

    -- swapfile
    swapfile = false,
}

-- custom variables
local vars = {
    -- netrw settings
    netrw_banner = 0,
    netrw_bufsettings = "noma nomod nu nobl nowrap ro",
    netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]],
    netrw_hide = 1,
    -- have_nerd_font = true,
}

-- TODO: replace todo-comments for this
-- vim.fn.matchadd("DiagnosticInfo", "\\(TODO:\\)")
-- vim.fn.matchadd("DiagnosticWarn", "\\(HACK:\\)")
-- vim.fn.matchadd("DiagnosticWarn", "\\(WARN:\\)")
-- vim.fn.matchadd("Identifier", "\\(PERF:\\)")
-- vim.fn.matchadd("DiagnosticHint", "\\(NOTE:\\)")
-- vim.fn.matchadd("Identifier", "\\(TEST:\\)")

-- LSP diagnostic config
vim.diagnostic.config({
    -- virtual_lines = true
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

-- apply options
for k, v in pairs(options) do
    vim.opt[k] = v
end

-- set variables
for k, v in pairs(vars) do
    vim.g[k] = v
end
