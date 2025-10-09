(import-macros {: pack! : require! : nmap} :macros)

(pack! [{:src "https://codeberg.org/mfussenegger/nvim-dap"
         :data {:cmd :DapNew
                :after (fn []
                         (local dap (require! :dap))
                         (set dap.adapters.delve
                              (fn [callback config]
                                (if (and (= config.mode :remote)
                                         (= config.request :attach))
                                    (callback {:type :server
                                               :host (or config.host :127.0.0.1)
                                               :port (or config.port :38697)})
                                    (callback {:type :server
                                               :port "${port}"
                                               :executable {:command :dlv
                                                            :args [:dap
                                                                   :-l
                                                                   "127.0.0.1:${port}"
                                                                   :--log
                                                                   :--log-output=dap]
                                                            :detached (= (vim.fn.has :win32)
                                                                         0)}}))))
                         (set dap.configurations.go
                              [{:type :delve
                                :name :Debug
                                :request :launch
                                :program "${file}"}
                               {:type :delve
                                :name "Debug test"
                                :request :launch
                                :mode :test
                                :program "${file}"}
                               {:type :delve
                                :name "Dubug test (go.mod)"
                                :request :launch
                                :mode :test
                                :program "./${relativeFileDirname}"}]))}}])
