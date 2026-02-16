(import-macros {: pack! : setup! : user-cmd!} :macros)

(let [opts {:formatters_by_ft {:lua [:stylua]
                               :javascript [:prettierd]
                               :typescript [:prettierd]
                               :javascriptreact [:prettierd]
                               :typescriptreact [:prettierd]
                               :html [:prettierd]
                               :css [:prettierd]
                               :go [:goimports :golangci-lint]
                               :nix [:nixfmt]
                               :rust [:rustfmt]
                               :python [:ruff]
                               :typst [:tinymist]
                               :yaml [:prettierd]
                               :json [:prettierd]
                               :fennel [:fnlfmt]
                               :markdown [:prettierd]
                               :templ [:templ]
                               :_ []}
            :format_on_save (fn [bufnr]
                              (when (not (. vim.b bufnr :disable_autoformat))
                                {:lsp_format :fallback :timeout_ms 500}))}]
  (pack! "https://github.com/stevearc/conform.nvim"
         {:event :BufWritePre
          :after (setup! :conform opts ((. (require :conform) :format)))}))

(user-cmd! :ConformDisable #(set vim.b.disable_autoformat true)
           {:desc "Disable autoformat-on-save"})

(user-cmd! :ConformEnable #(set vim.b.disable_autoformat false)
           {:desc "Re-enable autoformat-on-save"})
