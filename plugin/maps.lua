-- buffer switching
vim.keymap.set("n", "<leader>bn", vim.cmd.bnext, { desc = "bnext" })
vim.keymap.set("n", "<leader>bp", vim.cmd.bprev, { desc = "bprev" })
vim.keymap.set("n", "<leader>bd", function()
    vim.api.nvim_buf_delete(0, {})
end, { desc = "bdelete" })

-- Move by visual lines unless a count is supplied.
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- center cursor on navigation
for _, key in ipairs({ "<C-d>", "<C-u>", "{", "}", "(", ")", "*", "#", "g*", "g#", "G" }) do
    vim.keymap.set("n", key, key .. "zz")
end
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- move visual selections
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")
-- Better indents
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("x", "<", "<gv")
-- merge in place
vim.keymap.set("n", "J", "mzJ`z")
-- clear highlights on <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>", { silent = true })
-- exit terminal insert with <Esc>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { nowait = true })
-- unbind s
vim.keymap.set("n", "s", "<nop>", { silent = true })

-- commenting
for mode, command in pairs({ x = "normal gc", n = "normal gcc" }) do
    vim.keymap.set(mode, "<leader>/", function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd(command)
        vim.api.nvim_win_set_cursor(0, pos)
    end, { desc = "Toggle Comment", remap = true })
end
-- Netrw
vim.keymap.set("n", "<C-p>", function()
    if vim.bo.filetype == "netrw" then
        vim.cmd("bd")
    else
        vim.cmd("Explore")
    end
end)

-- diagnostic jumps
for key, get_diagnostic in pairs({
    ["]d"] = vim.diagnostic.get_next,
    ["[d"] = vim.diagnostic.get_prev,
}) do
    vim.keymap.set("n", key, function()
        local diagnostic = get_diagnostic({ severity = { min = vim.diagnostic.severity.WARN } })
        if diagnostic then
            vim.diagnostic.jump({ diagnostic = diagnostic })
        else
            vim.cmd("normal! zz")
        end
    end)
end
-- open diagnostics
-- TODO: applying this only when an LSP attaches would also save some time
vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { desc = "open floating diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "open diagnostics list" })

-- lsp
-- TODO: maybe only set these keymaps once an LSP attaches? (vim.lsp is a heavier part of the config)
-- - pendulum being a language server may make this pointless though
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "rename" })
vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, { desc = "signature help" })
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "goto declaration" })
vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "workspace add dir" })
vim.keymap.set(
    "n",
    "<leader>wr",
    vim.lsp.buf.remove_workspace_folder,
    { desc = "workspace remove dir" }
)
vim.keymap.set(
    "n",
    "<leader>wl",
    vim.lsp.buf.list_workspace_folders,
    { desc = "workspace list dirs" }
)
vim.keymap.set("n", "gt", function()
    vim.lsp.buf.type_definition()
    vim.cmd("normal! zz")
end, { desc = "goto type definition" })

-- Paste/delete without replacing the yank register.
vim.keymap.set("x", "<leader>d", function()
    vim.cmd("normal! _d")
end, { desc = "_d" })
vim.keymap.set("x", "<leader>p", function()
    vim.cmd("normal! _dP")
end, { desc = "_dP" })
-- make file executable
vim.keymap.set("n", "<leader>x+", "<cmd>silent !chmod +x %<CR>", { desc = "chmod +x" })
vim.keymap.set("n", "<leader>x-", "<cmd>silent !chmod -x %<CR>", { desc = "chmod -x" })
-- tmux-sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>sil !tmux neww ~/dotfiles/scripts/tmux-sessionizer.sh<CR>")
-- treesitter inspect
vim.keymap.set("n", "zS", vim.show_pos, { desc = "inspect" })
-- alternate file
vim.keymap.set("n", "<C-n>", "<C-^>zz")

-- navigate to next/prev TODO comments
local todo_pattern = "\\v\\s*(TODO|FIX|HACK|NOTE|DOCS|REFACTOR|CHANGE|REVIEW|FIX|TEST|DEBUG):\\s*"
vim.keymap.set("n", "]t", function()
    vim.fn.search(todo_pattern)
    vim.cmd("normal! zz")
end, { desc = "next todo comment" })
vim.keymap.set("n", "[t", function()
    vim.fn.search(todo_pattern, "b")
    vim.cmd("normal! zz")
end, { desc = "prev todo comment" })
-- yank file path
vim.keymap.set("n", "<leader>yf", function()
    vim.fn.setreg("+", vim.fn.expand("%"))
    vim.notify("Yanked: " .. vim.fn.expand("%"))
end, { desc = "yank path" })
vim.keymap.set("n", "<leader>ut", "<cmd>Undotree<CR>", { desc = "undotree" })
