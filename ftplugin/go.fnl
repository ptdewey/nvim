(import-macros {: autocmd! : imap} :macros)

(set vim.bo.expandtab false)

(macro lsp-action [pattern]
  `#(vim.lsp.buf.code_action {:filter #($1.title:match ,pattern) :apply true}))

(autocmd! :LspAttach {:callback #(imap :<C-f> (lsp-action :Fill))})
