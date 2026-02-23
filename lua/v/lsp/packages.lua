local M = {}

---@alias LspPackageSpec { envs: DevEnv[]? }
---@alias LspPackageGroup table<string, LspPackageSpec>

---Code formatters to auto-install
---@type LspPackageGroup
M.formatters = {
  eslint_d = { envs = { "dev", "work" } },
  prettier = { envs = { "dev", "work" } },
  prettierd = { envs = { "dev", "work" } },
  markdownlint = { envs = { "dev", "work" } },
  black = { envs = { "dev", "work" } },
  ["blackd-client"] = { envs = { "dev", "work" } },
  flake8 = { envs = { "dev", "work" } },
  mypy = { envs = { "dev", "work" } },
  vint = { envs = { "dev" } },
  stylua = { envs = { "dev", "work" } },
  systemdlint = { envs = { "dev", "remote" } },
}

---LSP Servers to auto-install
---@type LspPackageGroup
M.servers = {
  -- Most servers disabled due to mason-lspconfig validation errors
  -- Only keeping commonly working ones
  bashls = {},
  cssls = { envs = { "dev", "work" } },
  jsonls = {},
  lua_ls = {},
  pyright = { envs = { "dev", "work" } },
  ts_ls = { envs = { "dev", "work" } },

  -- Commented out due to mason-lspconfig errors:
  -- clangd = { envs = { "dev" } },
  -- cssmodules_ls = { envs = { "dev", "work" } },
  -- dockerls = { envs = { "dev", "remote" } },
  -- efm = {},
  -- elixirls = { envs = { "dev" } },
  -- emmet_ls = { envs = { "dev" } },
  -- graphql = { envs = { "dev", "work" } },
  -- html = { envs = { "dev", "work" } },
  -- hyprls = { envs = { "dev" } },
  -- protols = { envs = { "dev" } },
  -- pylsp = { envs = { "dev", "work" } },
  -- sqls = { envs = { "dev", "work" } },
  -- systemd_ls = { envs = { "dev", "remote" } },
  -- vimls = { envs = { "dev" } },
}

---@param grp LspPackageGroup
---@param env DevEnv?
---@return string[]
function M.in_env(grp, env)
  env = env or v.env
  return vim.iter(grp):fold({}, function(acc, pkg, spec)
    ---@cast acc string[]
    ---@cast pkg string
    ---@cast spec LspPackageSpec

    if not spec.envs or vim.tbl_contains(spec.envs, env) then
      table.insert(acc, pkg)
    end

    return acc
  end)
end

return M
