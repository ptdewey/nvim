(import-macros {: pack! : require! : setup! : nmap} :macros)

(pack! "https://github.com/nvim-mini/mini.nvim")

(macro mini-spec! [mod ...]
  (let [args [...]
        odd-len? (= 1 (% (length args) 2))
        [h opts] (if odd-len?
                     [(list (unpack args 1 (- (length args) 1)))
                      (. args (length args))]
                     [args {}])
        handlers (collect [i v (ipairs h) :into {} &until (= 0 (% i 2))]
                   (values v (. h (+ i 1))))]
    `(vim.tbl_deep_extend :force
                          {:name ,(.. :mini. mod)
                           :load (setup! ,(.. :mini. mod) ,opts)}
                          ,handlers)))

(macro mini! [mod ...]
  `(table.insert specs (mini-spec! ,mod ,...)))

(local specs [])

(mini! :ai :event [:BufReadPost :BufNewFile])

(mini! :jump :keys [:t :f :T :F])

(mini! :icons :on_require :mini.icons)

(mini! :notify :event :LspAttach)

(mini! :surround :keys [:S :sd :sf :sF :sh :cs :sn]
       {:mappings {:add :S :delete :sd :replace :cs}})

(mini! :git :cmd :Git :keys [:<leader>ga])
(nmap :<leader>ga "<cmd>Git add %<CR>" {:desc "git add"})

(mini! :visits :event :BufReadPost)
(nmap :<leader>v #(let [visits (require! :mini.visits)]
                    (visits.select_path)))

(mini! :diff :event :BufReadPost
       {:view {:style :sign
               :signs {:add "+" :change "~" :delete "-"}
               :priority 49}})

(nmap :<leader>gd #((. (require :mini.diff) :toggle_overlay)))

(mini! :indentscope :event [:BufReadPost :BufNewFile]
       {:draw {:delay 0
               :animation (let [indentscope (require :mini.indentscope)]
                            ((. indentscope.gen_animation :none)))}
        :symbol "▏"
        :options {:tray_as_border true}})

(mini! :starter (let [starter (require :mini.starter)]
                  {:items [(starter.sections.recent_files 5 true)
                           {:name "Find Files"
                            :action "lua require('fzf-lua').files({winopts={height=0.6,width=0.5,preview={hidden=true}}})"
                            :section "Quick Actions"}
                           {:name :Directories
                            :action "Pathfinder select"
                            :section "Quick Actions"}
                           (starter.sections.builtin_actions)]
                   :footer ""
                   :silent false}))

(mini! :hipatterns :event [:BufReadPost :BufNewFile]
       {:highlighters {:hex_color (let [hipatterns (require :mini.hipatterns)]
                                    ((. hipatterns.gen_highlighter :hex_color)))}})

(macro clue! [mode keys]
  `{:mode ,mode :keys ,keys})

(mini! :clue :keys [:<Leader>
                    :g
                    "'"
                    "\""
                    "["
                    "]"
                    :<C-w>
                    :z
                    {1 :<C-r> :mode [:i :c]}]
       (let [miniclue (require :mini.clue)]
         {:triggers [(clue! :n :<Leader>)
                     (clue! :x :<Leader>)
                     (clue! :n :g)
                     (clue! :x :g)
                     (clue! :n "'")
                     (clue! :x "'")
                     (clue! :n "[")
                     (clue! :n "]")
                     (clue! :n "\"")
                     (clue! :x "\"")
                     (clue! :i :<C-r>)
                     (clue! :c :<C-r>)
                     (clue! :n :<C-w>)
                     (clue! :n :z)
                     (clue! :x :z)]
          :clues [(miniclue.gen_clues.g)
                  (miniclue.gen_clues.square_brackets)
                  (miniclue.gen_clues.marks)
                  (miniclue.gen_clues.registers)
                  (miniclue.gen_clues.windows)
                  (miniclue.gen_clues.z)]
          :window {:delay 300}}))

; (mini! :files :event :UIEnter {:mappings {:go_out_plus "-" :go_in_plus :<CR>}})
; (nmap "-" (fn []
;             ((. (require :mini.files) :open))) {})

((. (require! :lze) :load) [specs])
