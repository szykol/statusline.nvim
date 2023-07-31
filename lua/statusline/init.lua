local get_branch_name = require('statusline.util').get_branch_name

local M = {}

M.colors = {
  bg            = '%#BG#',
  bg_inactive   = '%#BG_I#%',
  mode          = '%#Mode#',
  file_name     = '%#Filename#',

  ['i']     = '%#InsertMode#',
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
    {'BG_I', { fg = '#EBDBB2', bg = '#403C3C' }},
    {'Mode', { bg = '#403C3C', fg = '#EBDBB2', gui="bold" }},
    {'Filename', { bg = '#403C3C', fg = '#9B9889' }},

    {'InsertMode', { bg = '#403C3C', fg = '#b8ecff', gui="bold" }},
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
  local mode_str = string.upper(modes[current_mode][1])
  return string.format('  %s ', mode_str), color
end

M.get_file_name = function(_)
  return ' %f '
end

M.get_ln_col = function(_)
  return '%l:%c'
end

M.get_file_type = function(_)
  local file_type = vim.bo.filetype

  return file_type
end

M.get_percentage = function(_)
  return '%%%p'
end

M.set_inactive = function(self)
  local inactive_color = self.colors.bg_inactive;
  return inactive_color .. ' %f '
end

M.set_active = function(self)
  local colors = self.colors

  local current_mode, color = self:get_current_mode()
  local mode = color .. current_mode
  local file_name = colors.file_name .. self.get_file_name()
  local line_col = self.get_ln_col()
  local branch_name = get_branch_name() or ''
  branch_name = self.colors.file_name .. branch_name
  local file_type = color .. self.get_file_type()
  local percentage = self.get_percentage()

  return table.concat({
    mode,
    branch_name,
    "%=",
    file_name,
    "%m%r",
    "%=",
    file_type, ' ',
    colors.file_name, '[', percentage, ' ', line_col, ']',
  })
end

local start = function()
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
