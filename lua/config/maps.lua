local function _1_()
  return vim.cmd("Pendulum")
end
vim.keymap.set("n", "<leader>uh", _1_, {silent = true})
local function _2_()
  return vim.cmd("FzfLua")
end
vim.keymap.set("n", "<leader>uj", _2_, {desc = "text"})
local function _3_()
  local function _4_()
    return require("fzf-lua").buffers({winopts = {preview = {vertical = "down:35%", layout = "vertical"}}})
  end
  return _4_()
end
return vim.keymap.set("n", "<leader>uk", _3_, {desc = "text"})