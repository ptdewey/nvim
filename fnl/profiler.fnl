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

;; TODO: finish report generation
(fn M.report [opts]
  (let [opts (or opts {})
        results (M.get_results opts)
        limit (or opts.limit 50)]
    ;; TODO:
    (print :todo)))

(fn M.disable []
  (set M.enabled false))

(fn M.enable []
  (set M.enabled true))

; (fn M.setup []
;   (vim.api.nvim_create_user_command :ProfilerReport
;                                     (fn [args]
;                                       (M.report {:limit (or (tonumber args.args)
;                                                             20)}))
;                                     {:nargs "?"}))

M
