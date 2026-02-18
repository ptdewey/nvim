(import-macros {: pack! : setup!} :macros)

(let [opts {:log_file (vim.fn.expand :$HOME/.pendulum-log.csv)
            :timeout_len 180
            :timer_len 120
            :gen_reports true
            :top_n 5
            :time_zone :America/New_York
            :time_format :12h
            :report_section_excludes {}
            :report_excludes {:branch [:unknown_branch]
                              :directory []
                              :file ["ministarter://1/welcome"]
                              :filetype [:unknown_filetype :ministarter]
                              :project [:unknown_project]}}]
  (pack! (vim.fn.expand "file:///$HOME/projects/pendulum-nvim")
         {:version :v2 :after (setup! :pendulum opts)}))

; :lsp_binary (vim.fn.expand :$HOME/projects/pendulum-nvim/pendulum-server)})}}])
