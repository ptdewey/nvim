local pack = require("config.pack")

pack.add("https://github.com/ptdewey/yankbank-nvim", {
    version = "main",
    event = "VimEnter",
    after = function()
        require("yankbank").setup({
            sep = "------",
            max_entries = 9,
            num_behavior = "jump",
            focus_gain_poll = true,
            keymaps = {},
            -- persist_type = "sqlite",
            paste_register = "*",
            debug = true,
            bind_indices = "<leader>y",
        })
    end,
})

-- TODO: distinguish NixOS from other Linux systems.
if vim.uv.os_uname().sysname:lower() == "linux" then
    vim.g.sqlite_clib_path = "/run/current-system/sw/share/nix-ld/lib/libsqlite3.so"
end

vim.keymap.set("n", "<leader>p", "<cmd>YankBank<CR>", { noremap = true, desc = "yankbank" })
