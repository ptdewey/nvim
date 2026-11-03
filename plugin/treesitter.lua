local pack = require("config.pack")
pack.add("https://github.com/nvim-treesitter/nvim-treesitter", { version = "main" })

-- nvim-treesitter cannot be lazy-loaded.
require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
local ensure_installed = {
    "go",
    "bash",
    "markdown",
    "markdown_inline",
    "fennel",
    "query",
    "json",
    "yaml",
    "sql",
    "html",
    "toml",
}

vim.api.nvim_create_autocmd("FileType", {
    callback = function(event)
        local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].ft)
        if pcall(vim.treesitter.language.add, lang) then
            pcall(vim.treesitter.start, event.buf)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
    end,
})

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(event)
        local data = event.data
        if
            data.spec.name == "nvim-treesitter"
            and (data.kind == "install" or data.kind == "update")
        then
            if not data.active then
                vim.cmd("packadd nvim-treesitter")
            end
            local ok, treesitter = pcall(require, "nvim-treesitter")
            if ok then
                treesitter.install(ensure_installed):await()
            end
        end
    end,
})

-- Add no-op `is-not?` predicate to prevent errors with gleam queries
-- TODO: maybe PR a fix for this
vim.treesitter.query.add_predicate("is-not?", function()
    return true
end, { force = true })

vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
        local parsers = require("nvim-treesitter.parsers")
        local adoc_revision = "fc36cdfc2577c5c64fcb1b1e00c910d572713586"
        local adoc_url = "https://github.com/cathaysia/tree-sitter-asciidoc"
        parsers.asciidoc = {
            install_info = {
                url = adoc_url,
                revision = adoc_revision,
                location = "tree-sitter-asciidoc",
                queries = "tree-sitter-asciidoc/queries",
            },
        }
        parsers.asciidoc_inline = {
            install_info = {
                url = adoc_url,
                revision = adoc_revision,
                location = "tree-sitter-asciidoc_inline",
                queries = "tree-sitter-asciidoc_inline/queries",
            },
        }
        parsers.d2 = {
            install_info = {
                url = "https://github.com/ravsii/tree-sitter-d2",
                revision = "ffb66ce4c801a1e37ed145ebd5eca1ea8865e00f",
                queries = "queries",
            },
        }
        parsers.gleam = {
            install_info = {
                path = "/home/patrick/projects/open-source/tree-sitter-gleam",
                queries = "queries",
            },
        }
        parsers.snapshot = {
            install_info = {
                url = "https://github.com/ptdewey/shutter",
                revision = "3262e8451414b62a03e81bd2677dd299488db6f2",
                location = "editor/tree-sitter-snapshot",
                queries = "tree-sitter-snapshot/queries",
            },
        }
    end,
})
