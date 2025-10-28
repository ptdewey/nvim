(import-macros {: nmap : map : vmap : imap : tmap : normal!} :macros)

;; buffer switching
; (nmap :<tab> ":bnext <CR>zz" {:noremap true})
; (nmap :<S-tab> ":bprev <CR>zz" {:noremap true})

;; move up/down visual lines
(nmap :k "v:count == 0 ? 'gk' : 'k'" {:expr true :silent true})
(nmap :j "v:count == 0 ? 'gj' : 'j'" {:expr true :silent true})

;; center cursor on navigation
(each [_ key (ipairs [:<C-d> :<C-u> "{" "}" "(" ")" "*" "#" :g* "g#" :G])]
  (nmap key (.. key :zz)))

(nmap :n :nzzzv)
(nmap :N :Nzzzv)

;; move visual selections
(vmap :J ":m '>+1<CR>gv=gv")
(vmap :K ":m '<-2<CR>gv=gv")

;; merge in place
(nmap :J "mzJ`z")

;; clear highlights on <Esc>
(nmap :<Esc> :<cmd>noh<CR> {:silent true})
;; exit terminal insert with <Esc>
(tmap :<Esc> "<C-\\><C-n>" {:nowait true})
;; unbind s
(nmap :s :<nop> {:silent true})

;; commenting
(each [mode cmd (pairs {:x "normal gc" :n "normal gcc"})]
  (map mode :<leader>/
       (fn []
         (let [pos (vim.api.nvim_win_get_cursor 0)]
           (vim.cmd cmd)
           (vim.api.nvim_win_set_cursor 0 pos)))
       {:desc "Toggle Comment" :remap true}))

;; diagnostic jumps
(each [key cmd (pairs {"]d" vim.diagnostic.get_next
                       "[d" vim.diagnostic.get_prev})]
  (nmap key (fn []
              (let [d (cmd {:severity {:min vim.diagnostic.severity.WARN}})]
                (if d
                    (vim.diagnostic.jump {:diagnostic d})
                    (normal! :zz))))))

;; open diagnostics
(nmap :<leader>e vim.diagnostic.open_float {:desc "open floating diagnostic"})
(nmap :<leader>q vim.diagnostic.setloclist {:desc "open diagnostics list"})

;; lsp
(nmap :<leader>rn vim.lsp.buf.rename {:desc :rename})
(nmap :<leader>k vim.lsp.buf.signature_help {:desc "signature help"})
(imap :<C-k> vim.lsp.buf.signature_help)
(nmap :gD vim.lsp.buf.declaration {:desc "goto declaration"})
(nmap :<leader>wa vim.lsp.buf.add_workspace_folder {:desc "workspace add dir"})
(nmap :<leader>wr vim.lsp.buf.remove_workspace_folder
      {:desc "workspace remove dir"})

(nmap :<leader>wl vim.lsp.buf.list_workspace_folders
      {:desc "workspace list dirs"})

(nmap :gt (fn [] (vim.lsp.buf.type_definition) (normal! :zz))
      {:desc "goto type definition"})

;; paste/delete w/o yank
(vmap :<leader>d (fn [] (normal! :_d)) {:desc :_d})
(vmap :<leader>p (fn [] (normal! :_dP) {:desc :_dP}))

;; make file executable
(nmap :<leader>x+ "<cmd>silent !chmod +x %<CR>" {:desc "chmod +x"})
(nmap :<leader>x- "<cmd>silent !chmod -x %<CR>" {:desc "chmod -x"})

;; tmux-sessionizer
(nmap :<C-f> "<cmd>sil !tmux neww ~/dotfiles/scripts/tmux-sessionizer.sh<CR>")

;; treesitter inspect
(nmap :zS vim.show_pos {:desc :inspect})

;; alternate file
(nmap :<C-n> :<C-^>)

;; navigate to next/prev TODO comments
(let [todo-pattern "\\v\\s*(TODO|FIXME|HACK|NOTE|DOC|DOCS|REFACTOR|CHANGE):\\s*"]
  (nmap "]t" (fn [] (vim.fn.search todo-pattern)
               (normal! :zz)) {:desc "next todo comment"})
  (nmap "[t" (fn [] (vim.fn.search todo-pattern :b)
               (normal! :zz)) {:desc "prev todo comment"}))

;; yank file path
(nmap :<leader>yf
      (fn []
        (vim.fn.setreg "+" (vim.fn.expand "%"))
        (vim.notify (.. "Yanked: " (vim.fn.expand "%"))))
      {:desc "yank path"})

;; TODO: lazy load undotree plugin, load on first call
(nmap :<leader>ut :<cmd>Undotree<CR> {:desc :undotree})

(nmap :<leader>bd (fn [] (vim.api.nvim_buf_delete 0 {})) {:desc :bdelete})
(nmap :<leader>bn vim.cmd.bnext {:desc :bnext})
(nmap :<leader>bp vim.cmd.bprev {:desc :bprev})
