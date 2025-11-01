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
    (set timing-data.phases.require timing-data.require_time)
    (if success
        plugin
        (do
          (doto timing-data
            (tset :error plugin)
            (tset :total_time timing-data.require_time))
          (tset M.timings modname timing-data)
          (error (.. "Failed to require module '" modname "': " plugin))))))

;; Call setup function on plugin spec
(fn setup-plugin [plugin config timing-data]
  (if (and (= (type plugin) :table) plugin.setup)
      ;; TODO: case for if config is a function
      (let [setup-start (now)
            setup-config (or config {})
            [success error] (vals-pcall plugin.setup setup-config)]
        (doto timing-data
          (tset :setup_time (tdiff setup-start))
          (tset :setup_type :plugin_setup))
        (when (not success)
          (set timing-data.setup_error error))
        (set timing-data.phases.setup timing-data.setup_time))
      (do
        (doto timing-data
          (tset :setup_time 0)
          (tset :setup_type :no_setup))
        (set timing-data.phases.setup 0))))

;; DOCS:
;; TODO:
(fn after-plugin [plugin opts after-time]
  (when opts.after
    (let [after-start (now)
          [after-success after-error] (vals-pcall opts.after plugin)]
      (set after-time.after_time (tdiff after-start))
      (set after-time.phases.after after-time.after_time)
      (if (not after-success)
          (set after-time.after_error after-error)))))

;; DOCS:

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
                         :setup_config opts.setup
                         :timestamp (os.time)
                         :phases {}}
            ;; Phase 1: require the plugin
            plugin (require-plugin modname timing_data)]
        ;; Phase 2: Call plugin setup
        (setup-plugin plugin opts timing_data)
        ;; Phase 3: Post-setup operations
        (after-plugin plugin opts timing_data)
        ;; Final time calculations
        (set timing_data.total_time (tdiff total_start))
        (set timing_data.total timing_data.total_time)
        (tset M.timings modname timing_data)
        ;; Run on-complete callback if provided
        (if opts.on_complete
            (pcall opts.on_complete timing_data))
        plugin)))

(fn M.colorscheme [colorscheme-name]
  (if M.enabled
      (let [start-time (now)
            timing-data {:modname colorscheme-name
                         :setup_type :colorscheme
                         :timestamp start-time}]
        (vim.cmd (.. "colorscheme " colorscheme-name))
        (set timing-data.total_time (tdiff start-time))
        (tset M.timings (.. "colorscheme:" colorscheme-name) timing-data)
        timing-data.total_time)
      (vim.cmd (.. "colorscheme " colorscheme-name))))

;; DOCS:
(fn M.require [modname]
  (phased-load modname))

(fn M.require_and_setup [modname opts]
  (phased-load modname opts))

;; DOCS:
(fn M.get_results [opts]
  (let [opts (or opts {})
        sort_by (or opts.sort_by :total_time)]
    (doto (icollect [_ data (pairs M.timings)]
            (when (or (not opts.min_time) (>= data.total_time opts.min_time))
              data))
      (doto (table.sort (fn [a b]
                          (> (or (. a sort_by) 0) (or (. b sort_by) 0))))))))

(fn M.report [opts]
  (let [opts (or opts {})
        results (M.get_results opts)
        limit (or opts.limit 20)]
    (print (.. "\n" (string.rep "=" 85)))
    (print "PLUGIN PROFILER REPORT")
    (print (string.rep "=" 85))
    (var total-plugins 0)
    (var total-time 0)
    (var avg-time 0)
    (var lazy-loaded 0)
    (each [_ data (ipairs results)]
      (when (not (data.modname:match :^__batch_))
        (set total-plugins (+ total-plugins 1))
        (set total-time (+ total-time data.total_time))
        (when data.lazy_load
          (set lazy-loaded (+ lazy-loaded 1)))))
    (when (> total-plugins 0)
      (set avg-time (/ total-time total-plugins)))
    (print (string.format "Total Plugins: %d | Total Time: %.2fms | Average: %.2fms | Lazy Loaded: %d"
                          total-plugins total-time avg-time lazy-loaded))
    (print (string.rep "-" 85))
    (print (string.format "%-25s %10s %10s %10s %12s %8s" :Plugin "Total(ms)"
                          "Require(ms)" "Setup(ms)" "Setup Type" :Lazy))
    (print (string.rep "-" 85))
    (each [i data (ipairs results)]
      (when (<= i limit)
        (when (not (data.modname:match :^__batch_))
          (let [setup-type (or data.setup_type :none)
                lazy-marker (if data.lazy_load "✓" "")]
            (print (string.format "%-25s %10.2f %10.2f %10.2f %12s %8s"
                                  (data.modname:sub 1 25) data.total_time
                                  (or data.require_time 0)
                                  (or data.setup_time 0)
                                  (tostring (setup-type:sub 1 12)) lazy-marker))
            (when data.error
              (print (string.format "  ERROR: %s" data.error)))
            (when data.setup_error
              (print (string.format "  SETUP ERROR: %s" data.setup_error)))))))
    (print (string.rep "=" 85))))

(fn M.clear []
  (set M.timings {})
  (print "Plugin timing data cleared"))

(fn M.disable []
  (set M.enabled false))

(fn M.enable []
  (set M.enabled true))

(fn M.setup []
  (vim.api.nvim_create_user_command :ProfilerReport
                                    (fn [args]
                                      (let [limit (or (tonumber args.args) 20)]
                                        (M.report {: limit})))
                                    {:nargs "?"})
  (vim.api.nvim_create_user_command :ProfilerClear #(M.clear) {}))

M
