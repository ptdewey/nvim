(local M {:timings {} :enabled true})

(macro now [] `(vim.uv.hrtime))

;; TODO: figure out how to import macros to use "https://github.com/dokutan/typed_fennel"
(macro ns_to_ms [ns]
  `(/ ,ns 1000000))

(macro tdiff [time]
  `(ns_to_ms (- (now) ,time)))

;; Initialize a plugin with 'require("plugin")'
(fn require_plugin [name timing_data]
  (if (M.enabled)
      (do
        (local require_start (now))
        (local [success plugin] (pcall require name))
        (set timing_data.require_time (tdiff require_start))
        (set timing_data.phases.require timing_data.require_time)
        (when (not success)
          (do
            (set timing_data.error plugin)
            (set timing_data.total_time timing_data.require_time)
            (tset M.timings name timing_data)
            (error (string.format "Failed to require module '%s': %s" name
                                  plugin)))
          plugin))
      ;; Require plugin normally when not enabled
      (require name)))

;; Call setup function on plugin spec
(fn setup_plugin [plugin opts timing_data]
  (when (opts)
    (do
      (local setup_start (now))
      (var [setup_success setup_error] [nil nil])
      (if (= (type opts) :function)
          (do
            (set timing_data.setup_type :custom_function)
            (set [setup_success setup_error] (pcall opts plugin)))
          (or (= (type opts) :table) (= opts true))
          (do
            (set timing_data.setup_type :plugin_setup)
            (if (plugin.setup)
                (set [setup_success setup_error]
                     (pcall plugin.setup
                            (and (= (type opts) :table) (or opts {}))))
                (set setup_success false)
                (set setup_error
                     (string.format "Module 'todo' does not have a setup function"))))
          ;; TODO: get plugin name from table
          (set [setup_success setup_error]
               [false "Invalid setup option provided"]))
      (set timing_data.setup_time (tdiff setup_start))
      (set timing_data.phases.setup timing_data.setup_time)
      (if (not setup_success)
          (set timing_data.setup_error setup_error)))))

;; DOCS:
;; TODO:
(fn after_plugin [name opts plugin timing_data]
  (when (opts.after)
    (do
      (var after_start (now))
      (var [after_success after_error] (pcall opts.after plugin))
      (set timing_data.after_time (tdiff after_start))
      (set timing_data.phases.after timing_data.after_time)
      (if (not after_success)
          (set timing_data.after_error after_error)))))

;; DOCS:
(fn M.phased [name opts]
  (if (not M.enabled)
      (let [plugin (require name)]
        (if (and opts opts.setup)
            (if (= (type opts.setup) :function)
                ;; opts is function
                (opts.setup plugin)
                ;; opts is table
                (plugin.setup opts.setup)))
        plugin))
  (local total_start (now))
  (var opts (or opts {}))
  ;; initialize timing data
  (local timing_data {: name
                      :require_time 0
                      :setup_time 0
                      :total_time 0
                      :setup_config opts.setup
                      :timestamp (os.time)
                      :phases {}})
  ;; Phase 1: require the plugin
  (local plugin (require_plugin name timing_data))
  ;; Phase 2: Call plugin setup
  (setup_plugin plugin opts timing_data)
  ;; Phase 3: Post-setup operations
  (after_plugin name opts plugin timing_data)
  ;; Final time calculations
  (set timing_data.total_time (tdiff total_start))
  (set timing_data.total timing_data.total_time)
  (tset M.timings name timing_data)
  ;; Run on-complete callback if provided
  (if (opts.on_complete)
      (pcall opts.on_complete timing_data))
  plugin)

;; DOCS:
(fn M.require [name opts]
  (require_plugin name opts))

;; DOCS:
(fn M.profiled_setup [name opts]
  ;; TODO:
  )

;; DOCS:
(fn M.get_results [opts]
  (var opts (or opts {}))
  (local results {})
  (each [name data (pairs M.timings)]
    (if (not (and opts.min_time (< data.total_time opts.min_time)))
        (table.insert results data))
    (var sort_by (or opts.sort_by :total_time))
    (table.sort results
                (fn [a b]
                  (var a_val (or (. a sort_by) 0))
                  (var b_val (or (. b sort_by) 0)))))
  results)

;; TODO: finish report generation
(fn M.report [opts]
  (var opts (or opts {}))
  (local results (M.get_results opts))
  (local limit (or opts.limit 20))
  ;; TODO:
  )

M
