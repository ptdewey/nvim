return {
    name = "plantuml-lsp",
    filetypes = { "plantuml" },
    cmd = {
        vim.fn.expand("$HOME/projects/plantuml-lsp/plantuml-lsp"),
        vim.fn.expand("--stdlib-path=$HOME/Documents/plantuml-stdlib"),
        "--exec-path=plantuml",
        -- "--jar-path=/home/patrick/Downloads/plantuml-mit-1.2025.0.jar",
    },
    root_dir = vim.fs.root(0, ".git") or vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
}
