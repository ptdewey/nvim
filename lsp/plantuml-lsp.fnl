{:name :plantuml-lsp
 :filetypes [:plantuml]
 :cmd [(vim.fn.expand :$HOME/projects/plantuml-lsp/plantuml-lsp)
       (vim.fn.expand :--stdlib-path=$HOME/Documents/plantuml-stdlib
                      :--exec-path=plantuml)]
 :root_dir (or (vim.fs.root 0 :.git)
               (vim.fs.dirname (vim.api.nvim_buf_get_name 0)))}
