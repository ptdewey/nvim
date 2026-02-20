(import-macros {: nmap : user-cmd!} :macros)

(set vim.bo.tabstop 2)
(set vim.bo.shiftwidth 2)
(set vim.bo.commentstring "// %s")

(fn open-pdf []
  (let [filepath (vim.api.nvim_buf_get_name 0)]
    (when (filepath:match "%.typ$")
      (let [pdf-path (filepath:gsub "%.typ$" :.pdf)]
        (vim.system [:zathura pdf-path])))))

(nmap :<leader>co open-pdf {:desc "Open PDF Preview"})
(user-cmd! :OpenPdf open-pdf {})
