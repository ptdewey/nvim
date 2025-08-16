vim.keymap.set("n", "<tab>", ":bnext <CR>zz", {noremap = true})
vim.keymap.set("n", "<S-tab>", ":bprev <CR>zz", {noremap = true})
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", {expr = true, silent = true})
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", {expr = true, silent = true})
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")
vim.keymap.set("n", "g*", "g*zz")
vim.keymap.set("n", "g#", "g#zz")
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>", {silent = true})
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {nowait = true})
vim.keymap.set("n", "s", "<nop>", {silent = true})
for mode, cmd in pairs({x = "normal gc", n = "normal gcc"}) do
  local function _1_()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd(cmd)
    return vim.api.nvim_win_set_cursor(0, pos)
  end
  vim.keymap.set(mode, "<leader>/", _1_, {desc = "Toggle Comment", remap = true})
end
for key, cmd in pairs({["]d"] = vim.diagnostic.get_next, ["[d"] = vim.diagnostic.get_prev}) do
  local function _2_()
    local d = cmd()
    if d then
      return vim.diagnostic.jump({diagnostic = d})
    else
      return vim.cmd("normal! zz")
    end
  end
  vim.keymap.set("n", key, _2_)
end
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {desc = "open floating diagnostic"})
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {desc = "open diagnostics list"})
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {desc = "rename"})
vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, {desc = "signature help"})
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {desc = "goto declaration"})
vim.keymap.set("n", "wa", vim.lsp.buf.add_workspace_folder, {desc = "workspace add dir"})
vim.keymap.set("n", "wr", vim.lsp.buf.remove_workspace_folder, {desc = "workspace remove dir"})
vim.keymap.set("n", "wl", vim.lsp.buf.list_workspace_folders, {desc = "workspace list dirs"})
local function _4_()
  return vim.cmd("normal! \"_d")
end
vim.keymap.set({"v", "x"}, "<leader>d", _4_, {desc = "_d"})
local function _5_()
  vim.cmd("normal! \"_dP")
  return {desc = "_dP"}
end
vim.keymap.set({"v", "x"}, "<leader>p", _5_)
vim.keymap.set("n", "<leader>x+", "<cmd>silent !chmod +x %<CR>", {desc = "chmod +x"})
vim.keymap.set("n", "<leader>x-", "<cmd>silent !chmod -x %<CR>", {desc = "chmod -x"})
vim.keymap.set("n", "<C-f>", "<cmd>sil !tmux neww ~/dotfiles/scripts/tmux-sessionizer.sh<CR>")
vim.keymap.set("n", "zS", vim.show_pos, {desc = "inspect"})
for _, key in ipairs({"grn", "gri", "grr", "grt"}) do
  vim.keymap.del("n", key)
end
return vim.keymap.del({"n", "x"}, "gra")