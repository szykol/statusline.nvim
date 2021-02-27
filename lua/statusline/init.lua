local get_branch_name = require('statusline.util').get_branch_name

local M = {}

M.colors = {
  bg            = '%#BG#',
  bg_inactive   = '%#BG_I#%',
  mode          = '%#Mode#',
  file_name     = '%#Filename#',

  -- ['i']     = '%#InsertMode#',
}

local set_hl = function(group, options)
  local bg = options.bg == nil and '' or 'guibg=' .. options.bg
  local fg = options.fg == nil and '' or 'guifg=' .. options.fg
  local gui = options.gui == nil and '' or 'gui=' .. options.gui

  vim.cmd(string.format('hi %s %s %s %s', group, bg, fg, gui))
end

local set_highlights = function()
  local highlights = {
    {'BG', { fg = '#EBDBB2', bg = '#343434' }},
    {'BG_I', { fg = '#3C3836', bg = '#928374' }},
    {'Mode', { bg = '#403C3C', fg = '#EBDBB2', gui="bold" }},
    {'Filename', { bg = '#343434', fg = '#9B9889' }},

    {'InsertMode', { bg = '#403C3C', fg = '#FFFFFF' }},
  }
  for _, highlight in pairs(highlights) do
    set_hl(highlight[1], highlight[2])
  end
end

M.get_current_mode = function(self)
  local modes = {
    ['n']  = {'Normal', 'N'};
    ['no'] = {'N·Pending', 'N'} ;
    ['v']  = {'Visual', 'V' };
    ['V']  = {'V·Line', 'V' };
    [''] = {'V·Block', 'V'}; -- this is not ^V, but it's , they're different
    ['s']  = {'Select', 'S'};
    ['S']  = {'S·Line', 'S'};
    [''] = {'S·Block', 'S'}; -- same with this one, it's not ^S but it's 
    ['i']  = {'Insert', 'I'};
    ['R']  = {'Replace', 'R'};
    ['Rv'] = {'V·Replace', 'V'};
    ['c']  = {'Command', 'C'};
    ['cv'] = {'Vim Ex', 'V'};
    ['ce'] = {'Ex', 'E'};
    ['r']  = {'Prompt', 'P'};
    ['rm'] = {'More', 'M'};
    ['r?'] = {'Confirm', 'C'};
    ['!']  = {'Shell', 'S'};
    ['t']  = {'Terminal', 'T'};
  }

  local current_mode = vim.fn.mode()
  local color = self.colors[current_mode] or self.colors.mode
  return string.format('[%s]', modes[current_mode][1]), color
end

M.get_file_name = function(self)
  return ' %f '
end

M.get_ln_col = function(self)
  return ' [%l:%c] '
end

M.set_inactive = function(self)
  return ' %F '
end

M.set_active = function(self)
  local separator = ' '
  local colors = self.colors
  
  local current_mode, color = self:get_current_mode()
  local mode = color .. current_mode
  local file_name = colors.file_name .. self.get_file_name()
  local line_col = colors.bg .. self.get_ln_col()
  local branch_name = get_branch_name() or ''

  return table.concat({
    mode, file_name,
    colors.bg, branch_name,
    "%=",
    line_col
  })
end

start = function()
  set_highlights()
  Statusline = setmetatable(M, {
    __call = function(statusline, mode)
    if mode == "active" then return statusline:set_active() end
    if mode == "inactive" then return statusline:set_inactive() end
    end
  })

  -- TODO: replace this once we can define autocmd using lua
  vim.api.nvim_exec([[
    augroup Statusline
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
    au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
    augroup END
  ]], false)
end

return {
  start = start
}
