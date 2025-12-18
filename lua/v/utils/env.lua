local M = {}

---@alias DevEnv "dev"|"remote"|"work"

---@return boolean
local function is_work_env()
  local is_work_dir = vim.env.WORK_DIR
    and require("v.utils.paths").is_ancestor(vim.env.WORK_DIR, vim.uv.cwd() or "")

  if is_work_dir then
    return true
  end

  local git_conf_res = vim
    .system({
      "git",
      "config",
      "--get",
      "user.email",
    }, { text = true, timeout = 100 })
    :wait()
  return vim.trim(git_conf_res.stdout or ""):ends_with("@alt.xyz")
end

---@return DevEnv
function M.get_dev_env()
  local env_var = vim.env.DEVENV or vim.env.DEV_ENV --[[@as string?]]
  if env_var and env_var:lower() == "remote" then
    return "remote"
  elseif is_work_env() then
    return "work"
  else
    return "dev"
  end
end

return M
