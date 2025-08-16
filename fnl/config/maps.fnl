(macro map [mode key action opts]
  `(vim.keymap.set ,mode ,key ,action ,opts))

(macro nmap [key action opts]
  `(map :n ,key ,action ,opts))

(macro vmap [key action opts]
  `(map [:v :x] ,key ,action ,opts))

(macro imap [key action opts]
  `(map :i ,key ,action ,opts))

(macro del [mode key]
  `(vim.keymap.del ,mode ,key))

;; buffer switching
(nmap :<tab> ":bnext <CR>zz" {:noremap true})
(nmap :<S-tab> ":bprev <CR>zz" {:noremap true})

;; move up/down visual lines
(nmap :k "v:count == 0 ? 'gk' : 'k'" {:expr true :silent true})
(nmap :j "v:count == 0 ? 'gj' : 'j'" {:expr true :silent true})

;; center cursor on navigation
(nmap :<C-d> :<C-d>zz)
(nmap :<C-u> :<C-u>zz)
(nmap :n :nzzzv)
(nmap :N :Nzzzv)
(nmap "*" :*zz)
(nmap "#" "#zz")
(nmap :g* :g*zz)
(nmap "g#" "g#zz")

;; move visual selections
(map :x :J ":m '>+1<CR>gv=gv")
(map :x :K ":m '<-2<CR>gv=gv")

;; merge in place
(nmap :J "mzJ`z")

;; clear highlights on <Esc>
(nmap :<Esc> :<cmd>noh<CR> {:silent true})
;; exit terminal insert with <Esc>
(map :t :<Esc> "<C-\\><C-n>" {:nowait true})
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
              (let [d (cmd)]
                (if d (vim.diagnostic.jump {:diagnostic d})
                    (vim.cmd "normal! zz"))))))

;; open diagnostics
(nmap :<leader>e vim.diagnostic.open_float {:desc "open floating diagnostic"})
(nmap :<leader>q vim.diagnostic.setloclist {:desc "open diagnostics list"})

;; lsp
(nmap :<leader>rn vim.lsp.buf.rename {:desc :rename})
(nmap :<leader>k vim.lsp.buf.signature_help {:desc "signature help"})
(imap :<C-k> vim.lsp.buf.signature_help)
(nmap :gD vim.lsp.buf.declaration {:desc "goto declaration"})
(nmap :wa vim.lsp.buf.add_workspace_folder {:desc "workspace add dir"})
(nmap :wr vim.lsp.buf.remove_workspace_folder {:desc "workspace remove dir"})
(nmap :wl vim.lsp.buf.list_workspace_folders {:desc "workspace list dirs"})

;; paste/delete w/o yank
(vmap :<leader>d (fn [] (vim.cmd "normal! \"_d")) {:desc :_d})
(vmap :<leader>p (fn [] (vim.cmd "normal! \"_dP") {:desc :_dP}))

;; make file executable
(nmap :<leader>x+ "<cmd>silent !chmod +x %<CR>" {:desc "chmod +x"})
(nmap :<leader>x- "<cmd>silent !chmod -x %<CR>" {:desc "chmod -x"})

;; tmux-sessionizer
(nmap :<C-f> "<cmd>sil !tmux neww ~/dotfiles/scripts/tmux-sessionizer.sh<CR>")

;; treesitter inspect
(nmap :zS vim.show_pos {:desc :inspect})

;; delete unwanted lsp binds
(each [_ key (ipairs [:grn :gri :grr :grt])]
  (del :n key))

(del [:n :x] :gra)
