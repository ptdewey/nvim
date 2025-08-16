-- Helper function for using highlights from mini.icons
local function mini_hl(ctx)
    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
    return hl
end

return {
    {
        "saghen/blink.cmp",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "mikavilpas/blink-ripgrep.nvim",
            "mini.nvim",
        },
        event = "InsertEnter",

        version = "1.*",
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = "none",
                ["<C-h>"] = { "select_and_accept" },
                ["<C-space>"] = {
                    "show",
                    "show_documentation",
                    "hide_documentation",
                },
                ["<C-e>"] = { "hide" },
                ["<C-n>"] = { "select_next", "fallback_to_mappings" },
                ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = { auto_show = false },
                menu = {
                    draw = {
                        align_to = "cursor",
                        columns = {
                            { "label" },
                            { "kind_icon", "kind", "source_name", gap = 1 },
                        },
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local kind_icon, _, _ =
                                        require("mini.icons").get("lsp", ctx.kind)
                                    return kind_icon
                                end,
                                highlight = mini_hl,
                            },
                            kind = { highlight = mini_hl },
                            source_name = {
                                text = function(ctx)
                                    return "[" .. ctx.source_name .. "]"
                                end,
                                highlight = mini_hl,
                            },
                        },
                    },
                },
            },

            snippets = { preset = "luasnip" },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = {
                    "lazydev",
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                    "ripgrep",
                },

                providers = {
                    lsp = { score_offset = 45 },
                    snippets = { score_offset = 55 },
                    path = { score_offset = 10 },
                    buffer = { score_offset = 15 },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 46,
                    },
                    ripgrep = {
                        module = "blink-ripgrep",
                        name = "rg",
                        opts = {
                            backend = {
                                ripgrep = {
                                    max_filesize = "400K",
                                },
                            },
                        },
                        score_offset = 1,
                    },
                },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
}
