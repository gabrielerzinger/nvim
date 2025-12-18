local M = {}

---@param path string
---@returns boolean
M.file_exists = function(path)
  return vim.fn.filereadable(vim.fn.expand(path)) == 1
end

---@param path string
---@returns boolean
M.dir_exists = function(path)
  return vim.fn.isdirectory(vim.fn.expand(path)) == 1
end

---@param path string
---@returns string
M.resolve = function(path)
  return vim.fn.resolve(vim.fn.expand(path))
end

---@param base string
---@param target string
---@returns boolean
M.is_ancestor = function(base, target)
  local target_normalized = vim.fs.normalize(vim.fs.abspath(target))
  local base_normalized = vim.fs.normalize(vim.fs.abspath(base))
  return vim.fs.relpath(base_normalized, target_normalized) ~= nil
end

return M
