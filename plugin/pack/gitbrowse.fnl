(import-macros {: nmap : user-cmd!} :macros)

(fn git [dir ...]
  (let [args (table.concat [...] " ")
        out (vim.fn.system (.. "git -C " (vim.fn.shellescape dir) " " args))]
    (if (= vim.v.shell_error 0)
        (out:gsub "%s+$" "")
        nil)))

(fn ssh-to-https [url]
  (if (url:match "^git@")
      (-> url
          (: :gsub ":" "/" 1)
          (: :gsub "^git@" "https://"))
      (url:match "^ssh://")
      (url:gsub "^ssh://[^@]*@" "https://")
      url))

(fn repo-url [dir]
  (let [remote (git dir "config --get remote.origin.url")]
    (when (and remote (not= remote ""))
      (-> remote
          (: :gsub "%.git$" "")
          ssh-to-https))))

(fn get-link [filepath opts]
  (let [dir (vim.fn.fnamemodify filepath ":p:h")
        url (repo-url dir)]
    (when url
      (if (= opts.branch :default)
          url
          (let [branch (git dir "branch --show-current")]
            (if (and branch (not= branch ""))
                (.. url :/blob/ branch)
                url))))))

(fn open [opts]
  (let [opts (or opts {})
        filepath (vim.fn.expand "%:p")
        link (get-link filepath opts)]
    (if link
        (do
          (print link)
          (vim.ui.open link))
        (vim.notify "GitBrowse: not a git repository or no remote"
                    vim.log.levels.WARN))))

(nmap :<leader>gbb #(open) {:desc "browse current branch"})
(nmap :<leader>gbd #(open {:branch :default}) {:desc "browse default branch"})
(user-cmd! :GitBrowse #(open) {:desc "browse current branch"})
