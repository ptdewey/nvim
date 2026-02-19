; (import-macros {: pack! : require!} :macros)
;
; (macro smap [key action opts]
;   `(vim.keymap.set [:i :s] ,key ,action ,opts))
;
; (pack! "https://github.com/L3MON4D3/LuaSnip"
;        {:event :InsertEnter
;         :dep_of [:blink.cmp :gokit]
;         :after (fn []
;                  (local ls (require! :luasnip))
;                  (ls.setup {:enable_autosnippets true
;                             :update_events [:TextChanged :TextChangedI]}))})
