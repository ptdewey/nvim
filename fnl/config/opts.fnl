(macro o [key value]
  `(set (. vim.opt ,key) ,value))

(macro g [key value]
  `(set (. vim.g ,key) ,value))

;; core options
(o :number true)
(o :rnu true)
(o :autoindent true)
(o :scrolloff 8)
(o :splitright true)
(o :splitbelow true)
(o :showcmd true)
(o :mouse :a)
(o :shiftwidth 4)
(o :tabstop 4)
(o :expandtab true)
(o :smarttab true)
(o :breakindent true)

;; searching
(o :incsearch true)
(o :ignorecase true)
(o :smartcase true)

;; decrease update time
(o :updatetime 250)
(o :timeoutlen 300)

;; aesthetics
(o :termguicolors true)
(o :signcolumn :auto)
(o :background :dark)
(o :winborder :rounded)

;; undo/swap
(o :undofile true)
;; TODO: undodir
(o :swapfile false)

;; spellcheck
(o :spell true)
(o :spelllang :en_us)
(o :spellfile (vim.fn.expand :$HOME/.config/nvim/spell/en.utf-8.add))

;; completion
(o :completeopt "menuone,noselect")

;; system settings
(o :clipboard :unnamedplus)
(o :fileformats "unix,dos")

;; globals
(g :netrw_banner 0)
(g :netrw_hide 1)
(g :netrw_bufsettings "noma nomod nu nobl nowrap ro")
(g :netrw_list_hide "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+")

;; lsp diagnostics config
;; TODO: move this to a new file with lsp autocmds (and lsp plugins? -- when vim.pack switch happens)
(vim.diagnostic.config {;; :virtual_lines true
                        :virtual_text true
                        ;; (set update_in_insert true)
                        :float {:focusable false
                                :style :minimal
                                :border :rounded
                                :source true
                                :header ""
                                :prefix ""}})
