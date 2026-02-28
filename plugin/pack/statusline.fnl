(fn icon-for [category name fallback]
  (if (= _G.MiniIcons nil)
      fallback
      (let [(icon _) (_G.MiniIcons.get category name)]
        (or icon fallback))))

(fn mode-component []
  (let [m (: (. (vim.api.nvim_get_mode) :mode) :sub 1 1)
        ;; TODO: figure out the best groups to use here
        mode-map {:n [:NORMAL :ModeMsg]
                  :i [:INSERT :StlInsert]
                  :v [:VISUAL :StlVisual]
                  :V [:V-LINE :StlVisual]
                  "\022" [:V-BLOCK :StlVisual]
                  :R [:REPLACE :StlReplace]
                  :c [:COMMAND :StlCommand]
                  :t [:TERMINAL :StlInsert]
                  :s [:SELECT :StlVisual]
                  :S [:S-LINE :StlVisual]}]
    (let [info (or (. mode-map m) [:NORMAL :StlNormal])]
      (string.format "%%#%s# %s " (. info 2) (. info 1)))))

(fn filename-component []
  "%#StlFile# %f %m%r")

(fn sep []
  "%#StlFill#%=")

(fn location []
  "%#StlPos# %l:%c ")

(macro get-diagnostic-count [severity]
  `(length (vim.diagnostic.get buf
                               {:severity (. vim.diagnostic.severity ,severity)})))

;; TODO: turn some of this stuff into macros (i.e. insert, concat bits)
(fn diagnostics-component []
  (let [buf 0
        parts {}
        errs (get-diagnostic-count :ERROR)
        warns (get-diagnostic-count :WARN)
        infos (get-diagnostic-count :INFO)
        hints (get-diagnostic-count :HINT)]
    (when (> errs 0) (table.insert parts (.. "%#DiagnosticError#E:" errs)))
    (when (> warns 0) (table.insert parts (.. "%#DiagnosticWarn#W:" warns)))
    (when (> infos 0) (table.insert parts (.. "%#DiagnosticInfo#I:" infos)))
    (when (> hints 0) (table.insert parts (.. "%#DiagnosticHint#H:" hints)))
    (if (> (length parts) 0) (.. "%#StlDiag# " (table.concat parts " ") " ") "")))

(fn diff-component []
  (if (= _G.MiniDiff nil)
      ""
      (let [buf-data (_G.MiniDiff.get_buf_data 0)]
        (if (not buf-data)
            ""
            (let [s buf-data.summary
                  parts []]
              (when (and s (> (or s.add 0) 0))
                (table.insert parts (.. "%#Added#+" s.add)))
              (when (and s (> (or s.change 0) 0))
                (table.insert parts (.. "%#Changed#~" s.change)))
              (when (and s (> (or s.delete 0) 0))
                (table.insert parts (.. "%#Removed#-" s.delete)))
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
               "change_id.short(8)"] {:text true}
              (fn [result]
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
