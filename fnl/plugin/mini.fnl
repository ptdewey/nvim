(macro r! [module]
  "Shorthand for require"
  `(require ,module))

(macro s! [module ...]
  "Setup a module with optional config"
  (if (> (select "#" ...) 0)
      `((. (r! ,module) :setup) ,...)
      `((. (r! ,module) :setup))))

(macro m! [mode key action ...]
  "Create a keymap with optional opts"
  (let [opts (if (> (select "#" ...) 0) (select 1 ...) {})]
    `(vim.keymap.set ,mode ,key ,action ,opts)))

{:1 :echasnovski/mini.nvim
 :version false
 :config (fn []
           ;; better `a/i` text objects
           (s! :mini.ai)
           ;; better f/t motions
           (s! :mini.jump)
           (s! :mini.jump2d {:mappings {:start_jumping :s}})
           (s! :mini.icons)
           (s! :mini.tabline)
           (s! :mini.visits)
           ;; require("mini.pairs").s!({}) -- NOTE: doesn't function as well as autopairs
           (let [starter (r! :mini.starter)]
             (starter.s! {:items [{:name "Find Files"
                                   :action "lua require(\"fzf-lua\").files({winopts={preview={horizontal=\"right:65%\",layout=\"horizontal\"}}})"
                                   :section "Quick Actions"}
                                  {:name "Search Directories"
                                   :action "Pathfinder select"
                                   :section "Quick Actions"}
                                  {:name :Lazy
                                   :action :Lazy
                                   :section "Quick Actions"}
                                  {:name :Profile
                                   :action "Lazy profile"
                                   :section "Quick Actions"}
                                  (starter.sections.recent_files 5 true)
                                  (starter.sections.builtin_actions)]
                          :footer ""
                          :silent false}))
           (s! :mini.hipatterns
               {:highlighters {:hex_color ((. (r! :mini.hipatterns)
                                              :gen_highlighter :hex_color))}})
           (local get-git-root
                  (fn []
                    (let [result (vim.fn.systemlist "git rev-parse --show-toplevel 2>/dev/null")]
                      (if (and (= vim.v.shell_error 0) (> (length result) 0))
                          (. result 1)
                          (vim.fn.getcwd)))))
           (local open-index
                  (fn [i cwd]
                    (let [pins ((. (r! :mini.visits) :list_paths) (or cwd
                                                                      (get-git-root))
                                                                  {:filter :pin})]
                      (if (>= (length pins) i)
                          (vim.cmd (.. "edit " (. pins i)))
                          (print (.. "mini.visits: no pin with index '" i "'"))))))
           (m! :n :<leader>a
               (fn []
                 (let [path (vim.fn.expand "%:p")]
                   (when (not= path "")
                     (let [visits (r! :mini.visits)
                           pins (visits.list_paths (get-git-root)
                                                   {:filter :pin})
                           found-pin (accumulate [found false _ pin (ipairs pins)]
                                       (if (= pin path) true found))]
                       (if found-pin
                           (visits.remove_label :pin path)
                           (visits.add_label :pin path (get-git-root)))))))
               {:desc "[A]dd visit"})
           (each [i key (ipairs [:<C-h> :<C-j> :<C-k> :<C-l>])]
             (m! :n key #(open-index i)))
           (m! :n :<C-e>
               (fn []
                 ;; TODO: keybinds for removing from list (<C-x>)?
                 ((. (r! :mini.visits) :select_path) (get-git-root)
                                                     {:filter :pin})))
           (m! :n :<leader>vv
               (fn []
                 ((. (r! :mini.visits) :select_path) (get-git-root)))
               {:desc "[V]isits [V]iew"}))}
