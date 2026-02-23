local utils = require("v.lsp")

local M = {}

M.mappings = {
  { "n", "grp", utils.peek_definition },
  { "n", "grn", utils.rename_symbol },
  { "n", "K", utils.smart_hover_docs },
  { "n", "gh", utils.hover },
  { "n", "gq", vim.diagnostic.setqflist },
  { "n", "gs", utils.signature_help },
  { "n", "gl", vim.diagnostic.open_float },
  { "n", "yog", utils.toggle_diagnostics_visibility },
  {
    "n",
    "grr",
    function()
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.lsp_references()
      else
        vim.lsp.buf.references()
      end
    end,
    desc = "Goto References",
  },
  {
    "n",
    "gD",
    function()
      local ok, snacks = pcall(require, "snacks")
      if ok then
        snacks.picker.lsp_declarations({ unique_lines = true })
      else
        vim.lsp.buf.declaration()
      end
    end,
  },
  {
    "n",
    "gd",
    function()
      -- Custom handler that filters out import statements
      local function go_to_definition_skip_imports()
        local params = vim.lsp.util.make_position_params()

        vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, config)
          if err or not result then
            vim.notify("No definition found", vim.log.levels.WARN)
            return
          end

          -- Normalize result to array
          local locations = vim.tbl_islist(result) and result or { result }

          -- Filter out locations that are imports
          local filtered = {}
          for _, loc in ipairs(locations) do
            local uri = loc.uri or loc.targetUri
            local range = loc.range or loc.targetSelectionRange

            if uri and range then
              local bufnr = vim.uri_to_bufnr(uri)
              vim.fn.bufload(bufnr)

              local line_num = range.start.line
              local line = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1] or ""

              -- Skip if line contains import/export statement
              if not line:match("^%s*import%s") and not line:match("^%s*export%s.*from") then
                table.insert(filtered, loc)
              end
            end
          end

          -- Use filtered locations or fallback to all
          local final_locations = #filtered > 0 and filtered or locations

          if #final_locations == 1 then
            vim.lsp.util.jump_to_location(final_locations[1], "utf-8")
          elseif #final_locations > 1 then
            -- Try to use Telescope for better UI
            local ok, builtin = pcall(require, "telescope.builtin")
            if ok then
              builtin.lsp_definitions()
            else
              -- Fallback to quickfix list
              local items = vim.lsp.util.locations_to_items(final_locations, "utf-8")
              vim.fn.setqflist({}, ' ', {
                title = 'LSP Definitions',
                items = items
              })
              vim.cmd("copen")
            end
          end
        end)
      end

      -- For TypeScript/JavaScript files, use custom filter
      local ft = vim.bo.filetype
      if ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
        go_to_definition_skip_imports()
        return
      end

      -- For other languages, use Telescope
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.lsp_definitions()
      else
        vim.lsp.buf.definition()
      end
    end,
    desc = "Goto Definition",
  },
  {
    "n",
    "gi",
    function()
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.lsp_implementations()
      else
        vim.lsp.buf.implementation()
      end
    end,
    desc = "Goto Implementation",
  },
  {
    "n",
    "<Leader>fg",
    function()
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.diagnostics({ bufnr = 0 })
      end
    end,
    desc = "Diagnostics in Cur Buf",
  },
  {
    "n",
    "<Leader>fgg",
    function()
      local ok, builtin = pcall(require, "telescope.builtin")
      if ok then
        builtin.diagnostics()
      end
    end,
    desc = "Diagnostics Workspace",
  },
  {
    { "n", "v" },
    "gra",
    vim.lsp.buf.code_action,
    desc = "Code Actions",
  },
  {
    "n",
    "[g",
    function()
      vim.diagnostic.jump({ count = -1, float = true, _highest = true })
    end,
  },
  {
    "n",
    "]g",
    function()
      vim.diagnostic.jump({ count = 1, float = true, _highest = true })
    end,
  },
  {
    "n",
    "<leader>F",
    function()
      vim.lsp.buf.format({ async = true })
    end,
  },
}

return M
