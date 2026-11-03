-- Fix netrw navigation for a split keyboard (numpad '-' key).
vim.keymap.set("n", "<kMinus>", "<Plug>NetrwBrowseUpDir", { buffer = true, remap = false })
vim.keymap.set("n", "<kPlus>", "<Plug>NetrwLocalBrowseCheck", { buffer = true, remap = false })
