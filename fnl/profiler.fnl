(local M {:timings {} :enabled true})

(macro now [] `(vim.uv.hrtime))

(macro ns_to_ms [ns]
  `(/ ,ns 1000000))

(macro tdiff [time]
  `(ns_to_ms (- (now) ,time)))

(macro vals-pcall [...]
  `[(values (pcall ,...))])

;; Initialize a plugin with 'require("plugin")'
(fn require-plugin [modname timing-data]
  (let [require-start (now)
        [success plugin] (vals-pcall require modname)]
    (set timing-data.require_time (tdiff require-start))
    (if success
        plugin
        (do
          (doto timing-data
            (tset :error plugin)
            (tset :total_time timing-data.require_time))
          (tset M.timings modname timing-data)
          (error (.. "Failed to require module '" modname "': " plugin))))))

(fn setup-plugin [plugin config timing-data]
  (when (and (= (type plugin) :table) plugin.setup)
    (let [setup-start (now)
          setup-config (or config {})
          [success error] (vals-pcall plugin.setup setup-config)]
      (set timing-data.setup_time (tdiff setup-start))
      (when (not success)
        (set timing-data.setup_error error)))))

(fn phased-load [modname opts]
  (if (not M.enabled)
      (let [plugin (require modname)]
        (if (and opts opts.setup)
            (if (= (type opts.setup) :function)
                ;; opts is function
                (opts.setup plugin)
                ;; opts is table
                (plugin.setup opts.setup)))
        plugin)
      (let [;; TODO: pull total time stuff to a wrapping macro
            total_start (now)
            opts (or opts {}) ;; initialize timing data
            timing_data {: modname
                         :require_time 0
                         :setup_time 0
                         :total_time 0
                         :phase (if (= vim.v.vim_did_enter 1) :runtime
                                    :startup)
                         :trigger (or _G.__current_trigger :init)
                         :source :profiled}
            ;; Phase 1: require the plugin
            plugin (require-plugin modname timing_data)]
        ;; Phase 2: Call plugin setup
        (setup-plugin plugin opts timing_data)
        ;; Final time calculations
        (set timing_data.total_time (tdiff total_start))
        (tset M.timings modname timing_data)
        plugin)))

(fn M.colorscheme [colorscheme-name]
  (if M.enabled
      (let [start-time (now)
            timing-data {:modname colorscheme-name}]
        (vim.cmd (.. "colorscheme " colorscheme-name))
        (set timing-data.total_time (tdiff start-time))
        (tset M.timings (.. "colorscheme:" colorscheme-name) timing-data)
        timing-data.total_time)
      (vim.cmd (.. "colorscheme " colorscheme-name))))

(fn M.require [modname]
  (phased-load modname))

(fn M.require_and_setup [modname opts]
  (phased-load modname opts))

;; Wrap spec after/load callbacks to set trigger context for profiling
(fn M.wrap_triggers [spec]
  (let [trigger (or spec.event spec.cmd spec.keys spec.ft spec.on_require)
        trigger-str (when trigger
                      (if (= (type trigger) :table)
                          (table.concat trigger ",")
                          (tostring trigger)))]
    (when trigger-str
      (each [_ key (ipairs [:after :load])]
        (let [orig (. spec key)]
          (when orig
            (tset spec key (fn [...]
                             (set _G.__current_trigger trigger-str)
                             (let [result (orig ...)]
                               (set _G.__current_trigger nil)
                               result)))))))))

;; Merge global require timings into profiler data
;; Modules already tracked by phased-load take precedence
(fn merge-require-timings []
  (when _G.__require_timings
    (each [modname data (pairs _G.__require_timings)]
      (when (not (. M.timings modname))
        (tset M.timings modname data)))))

(fn M.get_results [opts]
  (merge-require-timings)
  (let [opts (or opts {})
        sort_by (or opts.sort_by :total_time)
        include-all (if (= opts.all nil) false opts.all)
        phase-filter opts.phase]
    (doto (icollect [_ data (pairs M.timings)]
            (when (and (or (not opts.min_time)
                           (>= data.total_time opts.min_time))
                       (or (not phase-filter) (= data.phase phase-filter))
                       (or include-all (not (= data.source :require))
                           (>= (or data.total_time 0) 0.5)))
              data))
      (doto (table.sort (fn [a b]
                          (> (or (. a sort_by) 0) (or (. b sort_by) 0))))))))

;; Highlight groups linked to standard groups (respects colorscheme)
(fn setup-highlights []
  (each [name opts (pairs {:ProfilerTitle {:link :Title}
                           :ProfilerSep {:link :NonText}
                           :ProfilerLabel {:link :Comment}
                           :ProfilerValue {:link :Number}
                           :ProfilerColHeader {:link :Bold}
                           :ProfilerModule {:link :Normal}
                           :ProfilerFast {:link :DiagnosticOk}
                           :ProfilerMedium {:link :DiagnosticInfo}
                           :ProfilerSlow {:link :DiagnosticWarn}
                           :ProfilerVerySlow {:link :DiagnosticError}
                           :ProfilerEvent {:link :Constant}
                           :ProfilerError {:link :DiagnosticError}})]
    (vim.api.nvim_set_hl 0 name (vim.tbl_extend :force opts {:default true}))))

(fn time-hl [ms]
  (if (>= ms 10) :ProfilerVerySlow
      (>= ms 3) :ProfilerSlow
      (>= ms 0.5) :ProfilerMedium
      :ProfilerFast))

;; Column layout for data rows
;; Format: "    %-32s  %10s    %10s    %10s    %-22s"
(local col {:mod 4
            :mod-end 36
            :total 38
            :total-end 48
            :req 52
            :req-end 62
            :setup 66
            :setup-end 76
            :event 80
            :event-end 102})

(fn build-report [opts]
  (let [opts (or opts {})
        results (M.get_results opts)
        phase-label (if opts.phase (.. " (" opts.phase ")") "")
        lines []
        hls []]
    ;; parallel array: each entry is list of [hl col_start col_end]
    ;; Helper: add line with highlight specs list

    (fn add [line hl-list]
      (table.insert lines line)
      (table.insert hls (or hl-list [])))

    ;; Compute summary stats
    (var total-plugins 0)
    (var startup-time 0)
    (var total-time 0)
    (each [_ data (ipairs results)]
      (when (not (data.modname:match :^__batch_))
        (set total-plugins (+ total-plugins 1))
        (set total-time (+ total-time data.total_time))
        (when (= data.phase :startup)
          (set startup-time (+ startup-time data.total_time)))))
    ;; Title
    (add "")
    (add (.. "    Profiler" phase-label) [[:ProfilerTitle 0 -1]])
    (add "")
    ;; Summary - build with tracked positions
    (let [summary-hls [[:ProfilerLabel 0 -1]]
          parts [{:text "    Startup: "}
                 {:text (string.format "%.2fms" startup-time)
                  :hl :ProfilerValue}
                 {:text "  │  Total: "}
                 {:text (string.format "%.2fms" total-time) :hl :ProfilerValue}
                 {:text "  │  Plugins: "}
                 {:text (tostring total-plugins) :hl :ProfilerValue}]]
      (var pos 0)
      (var summary "")
      (each [_ part (ipairs parts)]
        (set summary (.. summary part.text))
        (when part.hl
          (table.insert summary-hls [part.hl pos (+ pos (length part.text))]))
        (set pos (+ pos (length part.text))))
      (add summary summary-hls))
    ;; Separator + column headers
    (add (.. "    " (string.rep "─" 98)) [[:ProfilerSep 0 -1]])
    (add (string.format "    %-32s  %10s    %10s    %10s    %-22s" :Module
                        :Total :Require :Setup :Event)
         [[:ProfilerColHeader 0 -1]])
    (add (.. "    " (string.rep "─" 98)) [[:ProfilerSep 0 -1]])
    ;; Data rows
    (each [_ data (ipairs results)]
      (when (not (data.modname:match :^__batch_))
        (let [trigger (or data.trigger
                          (if (= data.phase :startup) :init :runtime))
              total (or data.total_time 0)
              req (or data.require_time 0)
              setup (or data.setup_time 0)
              line (string.format "    %-32s  %10.2f    %10.2f    %10.2f    %-22s"
                                  (data.modname:sub 1 32) total req setup
                                  (tostring (trigger:sub 1 22)))]
          (add line
               [[:ProfilerModule col.mod col.mod-end]
                [(time-hl total) col.total col.total-end]
                [(time-hl req) col.req col.req-end]
                [(time-hl setup) col.setup col.setup-end]
                [:ProfilerEvent col.event col.event-end]])
          (when data.error
            (add (.. "    ERROR: " data.error) [[:ProfilerError 0 -1]])
            (when data.setup_error
              (add (.. "    SETUP ERROR: " data.setup_error)
                   [[:ProfilerError 0 -1]]))))))
    (add "")
    {: lines : hls}))

(fn open-float [report]
  (setup-highlights)
  (let [{: lines : hls} report
        ns (vim.api.nvim_create_namespace :profiler_report)
        buf (vim.api.nvim_create_buf false true)]
    (let [pad 4
          width (math.min (+ col.event-end 8) (- vim.o.columns (* pad 2)))
          height (math.min (+ (length lines) 1) (- vim.o.lines (* pad 2) 2))
          row pad
          col-pos (math.floor (/ (- vim.o.columns width) 2))
          win (vim.api.nvim_open_win buf true
                                     {:relative :editor
                                      : width
                                      : height
                                      : row
                                      :col col-pos
                                      :style :minimal
                                      :border :rounded
                                      :title " Profiler "
                                      :title_pos :center})]
      ;; Set content
      (vim.api.nvim_buf_set_lines buf 0 -1 false lines)
      ;; Apply highlights via extmarks
      (each [i hl-list (ipairs hls)]
        (let [line-idx (- i 1)]
          (each [_ hl-spec (ipairs hl-list)]
            (let [[hl-group c-start c-end] hl-spec]
              (vim.api.nvim_buf_set_extmark buf ns line-idx c-start
                                            {:end_col (if (= c-end -1)
                                                          (length (. lines i))
                                                          c-end)
                                             :hl_group hl-group})))))
      ;; Buffer options
      (tset (. vim.bo buf) :modifiable false)
      (tset (. vim.bo buf) :bufhidden :wipe)
      ;; Close keymaps
      (let [close #(vim.api.nvim_win_close win true)]
        (vim.keymap.set :n :q close {:buffer buf})
        (vim.keymap.set :n :<Esc> close {:buffer buf})))))

(fn M.report [opts]
  (open-float (build-report opts)))

(fn M.setup []
  (vim.api.nvim_create_user_command :ProfilerReport
                                    (fn [args]
                                      (let [arg (or args.args "")
                                            show-all (arg:match :all)
                                            phase (or (arg:match :startup)
                                                      (arg:match :runtime))]
                                        (M.report {: phase :all show-all})))
                                    {:nargs "?"}))

M
