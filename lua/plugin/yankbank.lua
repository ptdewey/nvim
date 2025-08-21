vim.pack.add({
    { src = "https://github.com/ptdewey/sqlite.lua" },
    { src = "https://github.com/ptdewey/yankbank-nvim" },
})

-- band-aid solution for working with nix
vim.g.sqlite_clib_path = "/run/current-system/sw/share/nix-ld/lib/libsqlite3.so"

require("profiler").require_and_setup("yankbank", {
    sep = "------",
    max_entries = 9,
    -- num_behavior = "prefix",
    num_behavior = "jump",
    focus_gain_poll = true,
    keymaps = {},
    persist_type = "sqlite",
    debug = true,
    bind_indices = "<leader>y",
})

-- set popup keymap
vim.keymap.set("n", "<leader>p", "<cmd>YankBank<CR>", { noremap = true, desc = "Open YankBank" })
