(import-macros {: pack! : require!} :macros)

(macro smap [key action opts]
  `(vim.keymap.set [:i :s] ,key ,action ,opts))

(pack! "https://github.com/L3MON4D3/LuaSnip"
       {:event :InsertEnter
        :dep_of [:blink.cmp :gokit]
        :after (fn []
                 (local ls (require! :luasnip))
                 (ls.setup {:enable_autosnippets true
                            :update_events [:TextChanged :TextChangedI]})
                 ((. (require :luasnip.loaders.from_lua) :lazy_load) {:include nil
                                                                      :paths ["~/.config/nvim/lua/snippets"]})
                 (smap :<C-j>
                       (fn []
                         (when (ls.expand_or_jumpable) (ls.expand_or_jump)))
                       {:silent true})
                 (smap :<C-k> (fn [] (when (ls.jumpable -1) (ls.jump -1)))
                       {:silent true})
                 (smap :<C-l>
                       (fn [] (when (ls.choice_active) (ls.change_choice 1)))
                       {:silent true}))})
