(import-macros {: pack! : spec! : raw-setup! : setup! : user-cmd! : autocmd!}
               :macros)

(set vim.env.PATH (.. vim.env.PATH ":" (vim.fn.stdpath :data) :/mason/bin))

(pack! [(spec! "https://github.com/neovim/nvim-lspconfig")
        (spec! "https://github.com/williamboman/mason.nvim"
               {:cmd :Mason :after (setup! :mason)})
        (spec! "https://github.com/DNLHC/glance.nvim"
               {:cmd :Glance :after (setup! :glance)})
        (spec! "https://github.com/folke/lazydev.nvim"
               {:ft :lua
                :on_require :lazydev
                :after (setup! :lazydev
                               {:library [{:path "${3rd}/luv/library"
                                           :words ["vim%.uv"]}
                                          :lazy.nvim]})})])

;; TODO: also search `lsp/` for configs, append here.
;; This list primarily exists to pull lspconfig configs
(let [servers [:lua_ls
               :gopls
               :ts_ls
               :ruff
               :pyright
               :tinymist
               :harper_ls
               :rust_analyzer
               :just
               :nil_ls
               :fennel_ls
               :jsonls
               :html
               :cssls
               :gleam
               :tailwindcss
               :templ]]
  (each [_ server (ipairs servers)]
    (vim.lsp.enable server)))

(let [ag (vim.api.nvim_create_augroup :InlayHints {:clear true})
      cb (fn [args]
           (let [client (vim.lsp.get_client_by_id args.data.client_id)]
             (when (and client
                        (or (client:supports_method :textDocument/inlayHint)
                            client.server_capabilities.inlayHintProvider))
               (vim.lsp.inlay_hint.enable true {:bufnr args.buf}))))]
  (vim.cmd.highlight "default link LspInlayHint Comment")
  (autocmd! :LspAttach {:group ag :callback cb}))

;; Built in LSP auto-completion
; (let [cb (fn [args]
;            (let [client (vim.lsp.get_client_by_id args.data.client_id)]
;              (when (client:supports_method :textDocument/completion)
;                (vim.lsp.completion.enable true client.id args.buf
;                                           {:autotrigger true}))))]
;   (autocmd! :LspAttach {:callback cb}))
