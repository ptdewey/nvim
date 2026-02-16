(import-macros {: pack! : spec! : setup! : nmap : g} :macros)

(pack! [(spec! "https://github.com/vim-test/vim-test"
               {:cmd [:TestNearest :TestFile :TestSuite]})
        (spec! "https://github.com/ptdewey/nvim-coverage"
               {:cmd :Coverage
                :after (setup! :coverage
                               {:auto_reload true
                                :commands true
                                :lang {:go {:coverage_file :cover.out}}})})])

(g "test#strategy" :neovim)
(g "test#go#gotest#options" "-cover -coverprofile=cover.out")
(g "test#custom_transformations"
   {:cover (fn [cmd]
             (if (string.match cmd "go test")
                 (.. cmd " && go tool cover -func=cover.out")
                 cmd))})

(g "test#transformation" :cover)

(nmap :<leader>rt :<cmd>TestNearest<CR> {:desc "test nearest" :silent true})
(nmap :<leader>rf :<cmd>TestFile<CR> {:desc "test file" :silent true})
(nmap :<leader>ra :<cmd>TestSuite<CR> {:desc "test suite" :silent true})
