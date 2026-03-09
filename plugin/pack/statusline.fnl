;; Set to false if nerd font is missing/broken
;; Icon reference: https://www.nerdfonts.com/cheat-sheet
(local icons-enabled true)

(macro inv [group]
  ;; inverse of syntax groups (swap fg <-> bg)
  `(let [hl# (vim.api.nvim_get_hl 0 {:name ,group :link false})]
     {:fg hl#.bg :bg hl#.fg}))

(macro hl [group opts]
  `(vim.api.nvim_set_hl 0 ,group ,opts))

(vim.cmd.highlight "default link StlVisual Visual")

(->> {:callback (fn []
                  (hl :StlNormal (inv :ModeMsg))
                  (hl :StlInsert (inv :Special))
                  (hl :StlReplace (inv :Number))
                  (hl :StlCommand (inv :Comment)))}
     (vim.api.nvim_create_autocmd :ColorScheme))

(fn get-hl-bg [group]
  (. (vim.api.nvim_get_hl 0 {:name group :link false}) :bg))

(fn current-mode-info []
  (let [m (: (. (vim.api.nvim_get_mode) :mode) :sub 1 1)
        mode-map {:n [:NORMAL :StlNormal]
                  :i [:INSERT :StlInsert]
                  :v [:VISUAL :StlVisual]
                  :V [:V-LINE :StlVisual]
                  "\022" [:V-BLOCK :StlVisual]
                  :R [:REPLACE :StlReplace]
                  :c [:COMMAND :StlCommand]
                  :t [:TERMINAL :StlInsert]
                  :s [:SELECT :StlVisual]
                  :S [:S-LINE :StlVisual]}]
    (or (. mode-map m) [:NORMAL :StlNormal])))

(fn mode-component []
  (let [info (current-mode-info)
        hl-name (. info 2)]
    (vim.api.nvim_set_hl 0 :StlModeSep
                         {:fg (get-hl-bg hl-name) :bg (get-hl-bg :StatusLine)})
    (string.format "%%#%s# %s %%#StlModeSep#" hl-name (. info 1))))

(fn has-duplicate-name? [name full-path]
  (var found false)
  (each [_ buf (ipairs (vim.fn.getbufinfo {:buflisted 1}))]
    (when (and (not found) (not= buf.name full-path)
               (= (vim.fn.fnamemodify buf.name ":t") name))
      (set found true)))
  found)

(fn filename-component []
  (let [name (vim.fn.expand "%:t")]
    (if (= name "")
        "%#StlFile# [No Name] %m%r"
        (let [full-path (vim.fn.expand "%:p")
              display (if (has-duplicate-name? name full-path)
                          (.. (vim.fn.expand "%:p:h:t") "/" name)
                          name)]
          (.. "%#StlFile# " display " %m%r")))))

(fn sep []
  ;; Filler component
  "%#StlFill#%=")

(fn location []
  (let [hl-name (. (current-mode-info) 2)]
    (vim.api.nvim_set_hl 0 :StlPosSep
                         {:fg (get-hl-bg hl-name) :bg (get-hl-bg :StatusLine)})
    (.. "%#StlPosSep#%#" hl-name "# %l:%c ")))

(macro get-diagnostic-count [severity]
  `(length (vim.diagnostic.get buf
                               {:severity (. vim.diagnostic.severity ,severity)})))

(local diagnostic-icons
       (if icons-enabled
           ;; TODO: maybe define style sets, fill/outline, set those with condition?
           {:error " " :warn "󰀪 " :info "󰋽 " :hint " "}
           {:error "E:" :warn "W:" :info "I:" :hint "H:"}))

(macro diff-part [parts s field hl prefix]
  `(when (and ,s (> (or (. ,s ,field) 0) 0))
     (table.insert ,parts (.. "%#" ,hl "#" ,prefix (. ,s ,field)))))

(macro diag-part [parts severity hl icon-key]
  `(let [n# (get-diagnostic-count ,severity)]
     (when (> n# 0)
       (table.insert ,parts (.. "%#" ,hl "#" (. diagnostic-icons ,icon-key) n#)))))

(fn diagnostics-component []
  (let [buf 0
        parts {}]
    (diag-part parts :ERROR :DiagnosticError :error)
    (diag-part parts :WARN :DiagnosticWarn :warn)
    (diag-part parts :INFO :DiagnosticInfo :info)
    (diag-part parts :HINT :DiagnosticHint :hint)
    (if (> (length parts) 0) (.. "%#StlDiag#" (table.concat parts " ") " ") "")))

(fn diff-component []
  (if (= _G.MiniDiff nil)
      ""
      (let [buf-data (_G.MiniDiff.get_buf_data 0)]
        (if (not buf-data)
            ""
            (let [s buf-data.summary
                  parts []]
              (diff-part parts s :add :Added "+")
              (diff-part parts s :change :Changed "~")
              (diff-part parts s :delete :Removed "-")
              (if (> (length parts) 0)
                  (.. "%#StlDiff# " (table.concat parts " ") " ")
                  ""))))))

(var jj-info "")

(fn update-jj-info []
  (vim.system [:jj
               :log
               :-r
               "@"
               :--no-graph
               :--ignore-working-copy
               :-T
               "if(bookmarks, bookmarks.join(\", \"), change_id.short(8))"]
              {:text true} (fn [result]
                            (if (= result.code 0)
                                (set jj-info (vim.trim result.stdout))
                                (set jj-info "")))))

(vim.api.nvim_create_autocmd [:BufEnter :BufWritePost :FocusGained]
                             {:callback update-jj-info})

(fn jj-component []
  (if (= jj-info "") ""
      (.. "%#StlJJ# " jj-info " ")))

(fn _G.Statusline []
  (table.concat [(mode-component)
                 (filename-component)
                 (sep)
                 (diagnostics-component)
                 (diff-component)
                 (jj-component)
                 (location)]))

(set vim.o.statusline "%!v:lua.Statusline()")
