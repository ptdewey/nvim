(import-macros {: pack! : setup!} :macros)

(pack! [{:src "https://github.com/ptdewey/pendulum-nvim"
         :version :main
         :data {:event :UiEnter
                :after (setup! :pendulum
                               {:log_file (vim.fn.expand :$HOME/.pendulum-log.csv)
                                :timeout_len 180
                                :timer_len 120
                                :gen_reports true
                                :top_n 5
                                :time_zone :America/New_York
                                :time_format :12h
                                :report_section_excludes {}
                                :report_excludes {:branch [:unknown_branch]
                                                  :directory []
                                                  :file []
                                                  :filetype [:unknown_filetype]
                                                  :project [:unknown_project]}
                                :lsp_binary (vim.fn.expand :$HOME/projects/pendulum-nvim/pendulum-server)})}}])
