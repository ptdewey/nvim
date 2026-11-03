vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.opt_local.scrolloff = 5

-- Conceal wiki-link delimiters and list markers.
vim.fn.matchadd("Conceal", [[\[\[]], 10, -1, { conceal = "" })
vim.fn.matchadd("Conceal", "\\]\\]", 10, -1, { conceal = "" })
vim.fn.matchadd("Conceal", [[\v^(\s*)\zs-\ze ]], 10, -1, { conceal = "•" })
vim.fn.matchadd("Conceal", [[\v^(\s*)\zs\*\ze ]], 10, -1, { conceal = "•" })

-- Level 1 replaces delimiters with spaces; level 2 hides them.
vim.opt_local.conceallevel = 0
-- vim.opt_local.conceallevel = 1
-- vim.opt_local.conceallevel = 2

-- Hard wrap at 80 characters (seems to conflict w/obsidian.nvim)
-- vim.opt_local.textwidth = 80
-- vim.opt_local.formatoptions:append("tcq")
-- vim.opt_local.formatoptions:remove("l")
