(import-macros {: pack! :raw-setup! setup! : nmap : normal!} :macros)

(pack! [{:src "https://github.com/ibhagwan/fzf-lua"}])

(setup! :fzf-lua {:winopts {:height 0.85
                            :width 0.85
                            :preview {:default :builtin
                                      :vertical "down:40%"
                                      :layout :vertical}}
                  :fzf_opts {:--no-info ""
                             :--info :hidden
                             :--header " "
                             :--layout :reverse-list}
                  :files {:git_icons false
                          :file_icons true
                          :formatter :path.filename_first
                          :winopts {:height 0.6
                                    :width 0.5
                                    :preview {:hidden true}}}
                  :grep {:formatter :path.filename_first}
                  :file_ignore_patterns ["%.pdf$"]})

(macro vert [pct?]
  `{:layout :vertical :vertical (.. "down:" (or ,pct? "60%"))})

(macro fzf-map [key method opts desc]
  `(nmap ,key (fn []
                ((. (require :fzf-lua) ,method) ,opts))
         {:desc ,desc}))

(local fzf (require :fzf-lua))

(let [sel (fn [_ items]
            (let [h (/ (+ (length items) 4) vim.o.lines)
                  clamped-h (math.max 0.3 (math.min h 0.7))]
              {:winopts {:height clamped-h :width 0.4 :row 0.4}}))]
  (fzf.register_ui_select sel))

(nmap :<leader>f (fn [] (fzf.files)) {:desc :files})

(nmap :<leader>sg (fn []
                    (fzf.grep_project {:fzf_opts {:--nth :2..}})
                    {:desc :grep}))

(nmap :<leader>sb
      (fn []
        (fzf.grep_curbuf {:winopts {:height 0.6
                                    :width 0.5
                                    :preview {:hidden true}}}))
      {:desc "search buffer"})

(nmap :<leader>sh (fn [] (fzf.help_tags)) {:desc "search helptags"})

(nmap :<leader>d
      (fn []
        (fzf.diagnostics_workspace {:severity_limit vim.diagnostic.severity.INFO}))
      {:desc :diagnostics})

(nmap :<leader>b (fn [] (fzf.buffers)) {:desc :buffers})
(nmap :<leader>o (fn [] (fzf.buffers)) {:desc :buffers})

(nmap :<leader>tt
      (fn []
        (fzf.grep_project {:search "\\b(TODO|PERF|NOTE|FIX|FIXME|DOC|REFACTOR|BUG):"
                           :no_esc true
                           :winopts {:preview (vert "50%")}}))
      {:desc "search todo" :silent true})

(nmap :<leader>ca
      (fn []
        (fzf.lsp_code_actions {:winopts {:preview (vert)}}))
      {:desc "code action"})

(nmap :<leader>nf (fn [] (fzf.files {:cwd "~/notes"})) {:desc "note files"})

(nmap :<leader>ng (fn [] (fzf.grep_project {:cwd "~/notes" :hidden false}))
      {:desc "grep notes"})

(nmap :grr
      (fn []
        (fzf.lsp_references {:ignore_current_line true
                             :includeDeclaration false
                             :winopts {:default nil :preview (vert)}}))
      {:desc "goto references"})

(nmap :gd (fn [] (fzf.lsp_definitions) (normal! :zz))
      {:noremap true :desc "goto definition"})

;; TODO: make preview bigger (and horizontal)
(nmap :<leader>gs (fn [] (fzf.git_status)) {:noremap true :desc "git status"})

(nmap :<leader>ci (fn [] (fzf.lsp_incoming_calls))
      {:noremap true :desc "calls incoming"})

(nmap :<leader>co (fn [] (fzf.lsp_outgoing_calls))
      {:noremap true :desc "calls outgoing"})

(nmap :<leader>hh (fn [] (fzf.highlights)) {:desc "search highlights"})

(nmap :<leader>sm (fn [] (fzf.marks)) {:desc "search marks"})
