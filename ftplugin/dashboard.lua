vim.opt_local.foldenable = false

local alt_file = vim.fn.getreg("#")
local dashboard = require("v.plugins.navigation.dashboard.utils")
local k = require("v.utils.mappings")

k.map({
  "n",
  { "q", "<c-c>" },
  dashboard.quit_if_curr_buf,
  { buffer = true },
})
k.unmap({ "n", "<BS>", 0 })
vim.api.nvim_exec2("abbreviate <buffer> q qa", { output = false })

require("v.utils.autocmds").augroup("DashboardCleanup", {
  {
    event = "BufWinLeave",
    opts = {
      buffer = 0,
      once = true,
      callback = function(args)
        vim.api.nvim_create_autocmd("BufWinEnter", {
          group = "DashboardCleanup",
          once = true,
          callback = function()
            dashboard.delete_buf(args.buf, alt_file)
          end,
        })

        -- re-trigger FileType for lazy.nvim plugins that use `ft` loading
        vim.defer_fn(function()
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
              local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
              if ft and ft ~= "" then
                vim.api.nvim_buf_call(bufnr, function()
                  vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr })
                end)
              end
            end
          end
        end, 30)
      end,
    },
  },
})
