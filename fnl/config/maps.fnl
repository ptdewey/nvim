(macro m! [mode key action opts]
  `(vim.keymap.set ,mode ,key ,action ,opts))

(macro f! [...]
  `(fn [] (,...)))

(macro r! [module method ...]
  "Require and call method"
  `(fn []
     ((. (require ,module) ,method) ,...)))

(vim.keymap.set :n :<leader>uh (fn [] (vim.cmd :Pendulum)) {:silent true})

(m! :n :<leader>uj (f! vim.cmd :FzfLua) {:desc :text})
(m! :n :<leader>uk
    (f! (r! :fzf-lua :buffers
            {:winopts {:preview {:vertical "down:35%" :layout :vertical}}}))
    {:desc :text})
