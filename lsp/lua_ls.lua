vim.lsp.config["lua_ls"] = {
    settings = {
        Lua = {
            hint = {
                enable = true,
            },
            telemetry = { enable = false },
            globals = { "vim", "hs" },
            workspace = {
                library = {
                    vim.fn.expand(
                        "~/.hammerspoon/Spoons/EmmyLua.spoon/annotations"
                    ),
                },
                checkThirdParty = false,
            },
        },
    },
}
