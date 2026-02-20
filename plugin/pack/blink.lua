-- Helper function for using highlights from mini.icons
local p = require("profiler")

vim.pack.add({
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("1.*"),
        data = {
            event = "InsertEnter",
            dep_of = "obsidian.nvim",
            after = function()
                local function mini_hl(ctx)
                    local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                    return hl
                end

                -- p.require("luasnip")
                p.require("blink-ripgrep")
                p.require_and_setup("blink-cmp", {
                    keymap = {
                        preset = "none",
                        ["<C-h>"] = { "select_and_accept" },
                        ["<C-s>"] = {
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

                    signature = {
                        enabled = true,
                        -- trigger = { show_on_keyword = true },
                    },

                    completion = {
                        documentation = { auto_show = false },
                        ghost_text = { enabled = true },
                        menu = {
                            draw = {
                                -- treesitter = { "lsp" },
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

                    sources = {
                        default = {
                            "lsp",
                            "path",
                            "snippets",
                            "buffer",
                            "ripgrep",
                            "copilot",
                        },

                        per_filetype = {
                            lua = { inherit_defaults = true, "lazydev" },
                        },

                        providers = {
                            lsp = { score_offset = 45 },
                            snippets = { score_offset = 55 },
                            path = { score_offset = 15 },
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
                                        ripgrep = { max_filesize = "400K" },
                                    },
                                },
                                score_offset = 1,
                            },
                            copilot = {
                                name = "copilot",
                                module = "blink-copilot",
                                score_offset = 40,
                                async = true,
                            },
                        },
                    },

                    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
                    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
                    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
                    --
                    -- See the fuzzy documentation for more information
                    fuzzy = {
                        implementation = "prefer_rust_with_warning",
                        prebuilt_binaries = { force_version = "v1.6.0" },
                    },
                })
            end,
        },
    },
    {
        src = "https://github.com/mikavilpas/blink-ripgrep.nvim",
        data = { dep_of = "blink.cmp" },
    },
    {
        src = "https://github.com/fang2hou/blink-copilot",
        data = { dep_of = "blink.cmp" },
    },
}, require("pack").opts)
