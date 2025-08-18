(local M {:timings {} :enabled true})

(macro now [] `(vim.uv.hrtime))

;; TODO: figure out how to import macros to use "https://github.com/dokutan/typed_fennel"
(macro ns_to_ms [ns]
  `(/ ,ns 1000000))

(macro tdiff [time]
  `(ns_to_ms (- (now) ,time)))

(macro vals-pcall [...]
  `[(values (pcall ,...))])

;; Initialize a plugin with 'require("plugin")'
(fn require-plugin [modname timing_data]
  (local require_start (now))
  (local [success plugin] (vals-pcall require modname))
  (set timing_data.require_time (tdiff require_start))
  (set timing_data.phases.require timing_data.require_time)
  (if (not success)
      (do
        (doto timing_data
          (tset :error plugin)
          (tset :total_time timing_data.require_time))
        (tset M.timings modname timing_data)
        (error (string.format "Failed to require module '%s': %s" modname
                              plugin)))
      plugin))

;; Call setup function on plugin spec
;; TODO: work out what type 'opts' is (and rename it)
(fn setup-plugin [plugin config timing_data]
  (if (and (= (type plugin) :table) plugin.setup)
      (do
        (local setup_start (now))
        (local setup_config (or config {}))
        (local [success error] (vals-pcall plugin.setup setup_config))
        (doto timing_data
          (tset :setup_time (tdiff setup_start))
          (tset :setup_type :plugin_setup)
          (tset :setup_error (when (not success) error)))
        (set timing_data.phases.setup timing_data.setup_time))
      (do
        (doto timing_data
          (tset :setup_time 0)
          (tset :setup_type :no_setup))
        (set timing_data.phases.setup 0))))

;; DOCS:
;; TODO:
(fn after-plugin [plugin opts timing_data]
  (when opts.after
    (local after_start (now))
    (local [after_success after_error] (vals-pcall opts.after plugin))
    (set timing_data.after_time (tdiff after_start))
    (set timing_data.phases.after timing_data.after_time)
    (if (not after_success)
        (set timing_data.after_error after_error))))

;; DOCS:

(fn M.phased [modname opts]
  (if (not M.enabled)
      (do
        (local plugin (require modname))
        (if (and opts opts.setup)
            (if (= (type opts.setup) :function)
                ;; opts is function
                (opts.setup plugin)
                ;; opts is table
                (plugin.setup opts.setup)))
        plugin)
      (do
        ;; TODO: pull total time stuff to a wrapping macro
        (local total_start (now))
        (local opts (or opts {}))
        ;; initialize timing data
        (local timing_data {: modname
                            :require_time 0
                            :setup_time 0
                            :total_time 0
                            :setup_config opts.setup
                            :timestamp (os.time)
                            :phases {}})
        ;; Phase 1: require the plugin
        (local plugin (require-plugin modname timing_data))
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
      (do
        (local start-time (now))
        (local timing-data {:modname colorscheme-name
                            :setup_type :colorscheme
                            :timestamp start-time})
        (vim.cmd (.. "colorscheme " colorscheme-name))
        (set timing-data.total_time (tdiff start-time))
        (tset M.timings (.. "colorscheme:" colorscheme-name) timing-data)
        timing-data.total_time)
      (vim.cmd (.. "colorscheme " colorscheme-name))))

;; DOCS:
(fn M.require [modname]
  (M.phased modname))

(fn M.require_and_setup [modname opts]
  (M.phased modname opts))

;; DOCS:
(fn M.get_results [opts]
  (local opts (or opts {}))
  (local sort_by (or opts.sort_by :total_time))
  (doto (icollect [_ data (pairs M.timings)]
          (when (or (not opts.min_time) (>= data.total_time opts.min_time))
            data))
    (doto (table.sort (fn [a b]
                        (> (or (. a sort_by) 0) (or (. b sort_by) 0)))))))

;; TODO: finish report generation
(fn M.report [opts]
  (local opts (or opts {}))
  (local results (M.get_results opts))
  (local limit (or opts.limit 20))
  ;; TODO:
  )

(fn M.disable []
  (set M.enabled false))

(fn M.enable []
  (set M.enabled true))

M
