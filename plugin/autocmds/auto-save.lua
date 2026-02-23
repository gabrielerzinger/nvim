-- Auto-save configuration
-- Saves buffers automatically on various events to prevent data loss

local augroup = vim.api.nvim_create_augroup("AutoSave", { clear = true })

-- Helper function to check if buffer should be auto-saved
local function should_save(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if buffer is valid and modifiable
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  -- Don't save if buffer is not modifiable
  if not vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
    return false
  end

  -- Don't save if buffer hasn't been modified
  if not vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
    return false
  end

  -- Don't save if buffer has no name (scratch buffer)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return false
  end

  -- Don't save certain filetypes
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local ignore_filetypes = {
    "gitcommit",
    "gitrebase",
    "dashboard",
    "help",
    "oil",
    "NvimTree",
    "telescope",
    "TelescopePrompt",
    "TelescopeResults",
    "harpoon",
    "undotree",
    "diff",
    "fugitive",
    "qf",
  }

  for _, ft in ipairs(ignore_filetypes) do
    if filetype == ft then
      return false
    end
  end

  -- Don't save certain buffer types
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
  if buftype ~= "" and buftype ~= "acwrite" then
    return false
  end

  return true
end

-- Auto-save function
local function auto_save()
  local bufnr = vim.api.nvim_get_current_buf()

  if should_save(bufnr) then
    -- Use pcall to prevent errors from disrupting workflow
    local ok, err = pcall(function()
      vim.cmd("silent! write")
    end)

    if not ok then
      -- Only log errors, don't show to user
      vim.schedule(function()
        vim.notify(
          string.format("Auto-save failed: %s", err),
          vim.log.levels.WARN,
          { title = "Auto-Save" }
        )
      end)
    end
  end
end

-- Save on focus lost (switching to another app)
vim.api.nvim_create_autocmd("FocusLost", {
  group = augroup,
  pattern = "*",
  callback = auto_save,
  desc = "Auto-save on focus lost",
})

-- Save on buffer leave (switching buffers)
vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup,
  pattern = "*",
  callback = auto_save,
  desc = "Auto-save on buffer leave",
})

-- Save after being idle (updatetime = 300ms in your config)
vim.api.nvim_create_autocmd("CursorHold", {
  group = augroup,
  pattern = "*",
  callback = auto_save,
  desc = "Auto-save on cursor hold (idle)",
})

-- Save when entering insert mode (optional, might be too aggressive)
-- Uncomment if you want even more frequent saves
-- vim.api.nvim_create_autocmd("InsertLeave", {
--   group = augroup,
--   pattern = "*",
--   callback = auto_save,
--   desc = "Auto-save on leaving insert mode",
-- })

-- Create command to toggle auto-save
vim.api.nvim_create_user_command("ToggleAutoSave", function()
  local disabled = vim.g.auto_save_disabled or false

  if disabled then
    vim.api.nvim_create_augroup("AutoSave", { clear = false })
    vim.g.auto_save_disabled = false
    vim.notify("Auto-save enabled", vim.log.levels.INFO, { title = "Auto-Save" })
  else
    vim.api.nvim_create_augroup("AutoSave", { clear = true })
    vim.g.auto_save_disabled = true
    vim.notify("Auto-save disabled", vim.log.levels.INFO, { title = "Auto-Save" })
  end
end, {
  desc = "Toggle auto-save on/off",
})
