local Job = require('plenary.job')

local get_branch_name = function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local job = Job:new({
    command = "git",
    args = {"branch", "--show-current"},
    cwd = vim.fn.fnamemodify(bufname, ":h"),
  })

  local ok, result = pcall(function()
    return vim.trim(job:sync()[1])
  end)

  if ok then
    return result
  end
end

return {
  get_branch_name = get_branch_name
}
