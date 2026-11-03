local pack = require("config.pack")
pack.add("https://github.com/ibhagwan/fzf-lua")

local fzf = require("fzf-lua")
fzf.setup({
    winopts = {
        height = 0.85,
        width = 0.85,
        preview = { default = "builtin", vertical = "down:40%", layout = "vertical" },
    },
    fzf_opts = {
        ["--no-info"] = "",
        ["--info"] = "hidden",
        ["--header"] = " ",
        ["--layout"] = "reverse-list",
    },
    files = {
        git_icons = false,
        file_icons = true,
        -- formatter = "path.filename_first",
        winopts = { height = 0.6, width = 0.5, preview = { hidden = true } },
    },
    grep = { formatter = "path.filename_first" },
    file_ignore_patterns = { "%.pdf$" },
})

local function vertical(percent)
    return { layout = "vertical", vertical = "down:" .. (percent or "60%") }
end
fzf.register_ui_select(function(_, items)
    local height = (#items + 4) / vim.o.lines
    return { winopts = { height = math.max(0.3, math.min(height, 0.7)), width = 0.4, row = 0.4 } }
end)

vim.keymap.set("n", "<leader>f", function()
    fzf.files()
end, { desc = "files" })
vim.keymap.set("n", "<leader>sg", function()
    fzf.grep_project({ fzf_opts = { ["--nth"] = "2.." } })
end, { desc = "grep" })
vim.keymap.set("n", "<leader>sb", function()
    fzf.grep_curbuf({ winopts = { height = 0.6, width = 0.5, preview = { hidden = true } } })
end, { desc = "search buffer" })
vim.keymap.set("n", "<leader>sh", function()
    fzf.help_tags()
end, { desc = "search helptags" })
vim.keymap.set("n", "<leader>d", function()
    fzf.diagnostics_workspace({ severity_limit = vim.diagnostic.severity.INFO })
end, { desc = "diagnostics" })
vim.keymap.set("n", "<leader>bb", function()
    fzf.buffers()
end, { desc = "buffers" })
vim.keymap.set("n", "<leader>o", function()
    fzf.buffers()
end, { desc = "buffers" })
vim.keymap.set("n", "<leader>st", function()
    fzf.grep_project({
        search = "\\b(TODO|PERF|NOTE|FIX|FIXME|DOCS|REFACTOR|BUG|REVIEW|TEST):",
        no_esc = true,
        winopts = { preview = vertical("50%") },
    })
end, { desc = "search todo", silent = true })
vim.keymap.set("n", "<leader>ca", function()
    fzf.lsp_code_actions({ winopts = { preview = vertical() } })
end, { desc = "code action" })
vim.keymap.set("n", "<leader>nf", function()
    fzf.files({ cwd = "~/notes" })
end, { desc = "note files" })
vim.keymap.set("n", "<leader>ng", function()
    fzf.grep_project({ cwd = "~/notes", hidden = false })
end, { desc = "grep notes" })
vim.keymap.set("n", "grr", function()
    fzf.lsp_references({
        ignore_current_line = true,
        includeDeclaration = false,
        winopts = { preview = vertical() },
    })
end, { desc = "lsp references" })
vim.keymap.set("n", "gri", function()
    fzf.lsp_implementations({ deault = nil, priview = vertical() })
end, { desc = "lsp implementation" })
vim.keymap.set("n", "gd", function()
    fzf.lsp_definitions()
    vim.cmd("normal! zz")
end, { noremap = true, desc = "goto definition" })
-- TODO: make preview bigger (and horizontal)
vim.keymap.set("n", "<leader>gs", function()
    fzf.git_status()
end, { noremap = true, desc = "git status" })
vim.keymap.set("n", "<leader>ci", function()
    fzf.lsp_incoming_calls()
end, { noremap = true, desc = "calls incoming" })
vim.keymap.set("n", "<leader>co", function()
    fzf.lsp_outgoing_calls()
end, { noremap = true, desc = "calls outgoing" })
vim.keymap.set("n", "<leader>hh", function()
    fzf.highlights()
end, { desc = "search highlights" })
vim.keymap.set("n", "<leader>sm", function()
    fzf.marks()
end, { desc = "search marks" })
vim.keymap.set("n", "<leader>sl", function()
    fzf.grep({ resume = true })
end, { desc = "grep last" })
