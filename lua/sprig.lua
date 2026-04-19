local vim = _G.vim
local M = {}
local config_dir = vim.fn.stdpath("config")
local cache_dir = (vim.fn.stdpath("cache") .. "/sprig")
local config_cache = {}
local fennel_path = "/deps/fennel-1.6.1.lua"
local function find_config(fnl_path)
  local dir = vim.fn.fnamemodify(fnl_path, ":h")
  local cached = config_cache[dir]
  if (cached == false) then
    return nil, nil
  elseif (cached ~= nil) then
    return cached.config, cached.root
  else
    local found = vim.fn.findfile(".sprig.lua", (dir .. ";"))
    if (found == "") then
      config_cache[dir] = false
      return nil, nil
    else
      local config_path = vim.fn.fnamemodify(found, ":p")
      local root = vim.fn.fnamemodify(config_path, ":h")
      local ok, cfg = pcall(dofile, config_path)
      local cfg0
      if (ok and (type(cfg) == "table")) then
        cfg0 = cfg
      else
        cfg0 = {}
      end
      config_cache[dir] = {config = cfg0, root = root}
      return cfg0, root
    end
  end
end
local function is_ignored(fnl_path, cfg, root)
  if (cfg and cfg.ignore) then
    local rel = fnl_path:sub((#root + 2))
    local found = false
    for _, pattern in ipairs(cfg.ignore) do
      if found then break end
      found = (found or (nil ~= rel:match(pattern)))
    end
    return found
  else
    return false
  end
end
local function is_macro_file(fnl_path, cfg, root)
  if (cfg and cfg.macros) then
    local rel = fnl_path:sub((#root + 2))
    local found = false
    for _, pattern in ipairs(cfg.macros) do
      if found then break end
      found = (found or (nil ~= rel:match(pattern)))
    end
    return found
  else
    return false
  end
end
local function fnl_to_lua_path(fnl_path, cfg, root)
  local rel = fnl_path:sub((#root + 2))
  local _6_
  if (cfg and cfg.paths) then
    local result = nil
    for pattern, replacement in pairs(cfg.paths) do
      if result then break end
      local mapped = rel:gsub(pattern, replacement)
      if (mapped ~= rel) then
        result = (root .. "/" .. mapped)
      else
      end
    end
    _6_ = result
  else
    _6_ = nil
  end
  local or_9_ = _6_
  if not or_9_ then
    local remapped = rel:gsub("^fnl/", "lua/"):gsub("%.fnl$", ".lua")
    or_9_ = (cache_dir .. "/" .. remapped)
  end
  return or_9_
end
local function get_fennel()
  if M._fennel then
    return M._fennel
  else
    local chunk = loadfile((config_dir .. fennel_path))
    local saved_arg = arg
    local saved_print = print
    arg = {"--version"}
    local function _11_()
    end
    print = _11_
    pcall(chunk)
    arg = saved_arg
    print = saved_print
    local fennel = require("fennel")
    local macro_path = (config_dir .. "/fnl/?.fnl;" .. config_dir .. "/fnl/?/init.fnl")
    fennel["macro-path"] = (macro_path .. ";" .. (fennel["macro-path"] or ""))
    M._fennel = fennel
    return fennel
  end
end
M.compile = function(fnl_path)
  local fnl_path0 = vim.fn.resolve(fnl_path)
  local cfg, root = find_config(fnl_path0)
  if (root and not is_ignored(fnl_path0, cfg, root) and not is_macro_file(fnl_path0, cfg, root)) then
    local f = io.open(fnl_path0, "r")
    if not f then
      return vim.notify(("sprig: cannot read " .. fnl_path0), vim.log.levels.ERROR)
    else
      local source = f:read("*a")
      f:close()
      local fennel = get_fennel()
      local compiler_opts = ((cfg and cfg.compiler) or {})
      local compile_opts = {filename = fnl_path0, compilerEnv = (compiler_opts.compilerEnv or _G), allowGlobals = (compiler_opts.allowGlobals ~= false), correlate = (compiler_opts.correlate or false)}
      local saved_macro_path
      if (root ~= config_dir) then
        saved_macro_path = fennel["macro-path"]
      else
        saved_macro_path = nil
      end
      if (root ~= config_dir) then
        fennel["macro-path"] = (root .. "/fnl/?.fnl;" .. root .. "/fnl/?/init.fnl;" .. fennel["macro-path"])
      else
      end
      local ok, result = pcall(fennel.compileString, source, compile_opts)
      if saved_macro_path then
        fennel["macro-path"] = saved_macro_path
      else
      end
      if not ok then
        return vim.notify(("sprig: " .. tostring(result)), vim.log.levels.ERROR)
      else
        local lua_path = fnl_to_lua_path(fnl_path0, cfg, root)
        vim.fn.mkdir(vim.fn.fnamemodify(lua_path, ":h"), "p")
        local out = io.open(lua_path, "w")
        if not out then
          return vim.notify(("sprig: cannot write " .. lua_path), vim.log.levels.ERROR)
        else
          out:write(result)
          return out:close()
        end
      end
    end
  else
    return nil
  end
end
M.clean = function()
  local lua_files = vim.fn.globpath(cache_dir, "**/*.lua", false, true)
  local removed = 0
  for _, lua_path in ipairs(lua_files) do
    local rel = lua_path:sub((#cache_dir + 2)):gsub("^lua/", "fnl/"):gsub("%.lua$", ".fnl")
    local fnl_path = (config_dir .. "/" .. rel)
    if (vim.fn.filereadable(fnl_path) == 0) then
      os.remove(lua_path)
      removed = (removed + 1)
    else
    end
  end
  if (removed > 0) then
    return vim.notify(("sprig: removed " .. removed .. " orphaned files"))
  else
    return nil
  end
end
M.compile_all = function(_3froot)
  local root = (_3froot or config_dir)
  local files = vim.fn.globpath(root, "**/*.fnl", false, true)
  local count = 0
  for _, fnl_path in ipairs(files) do
    M.compile(fnl_path)
    count = (count + 1)
  end
  M.clean()
  return vim.notify(("sprig: compiled " .. count .. " files"))
end
M.setup = function()
  do
    local existing = vim.fn.globpath(cache_dir, "**/*.lua", false, true)
    if (#existing == 0) then
      M.compile_all()
      package.path = (cache_dir .. "/lua/?.lua;" .. cache_dir .. "/lua/?/init.lua;" .. package.path)
      vim.loader.reset()
    else
    end
  end
  local group = vim.api.nvim_create_augroup("sprig", {clear = true})
  local function _23_(ev)
    return M.compile(ev.match)
  end
  vim.api.nvim_create_autocmd("BufWritePost", {pattern = "*.fnl", group = group, callback = _23_})
  local function _24_()
    return M.compile_all()
  end
  vim.api.nvim_create_user_command("SprigCompileAll", _24_, {desc = "Compile all .fnl files to .lua"})
  local function _25_()
    vim.fn.delete(cache_dir, "rf")
    return vim.notify(("sprig: cleared " .. cache_dir))
  end
  return vim.api.nvim_create_user_command("SprigClean", _25_, {desc = "Remove all compiled .lua files from the sprig cache"})
end
return M