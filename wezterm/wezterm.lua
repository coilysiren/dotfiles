-- WezTerm cross-platform config.
-- Symlinked to ~/.wezterm.lua on Mac/Linux, %USERPROFILE%\.wezterm.lua on Windows.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 13.0
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }
config.use_fancy_tab_bar = false
config.scrollback_lines = 50000
config.audible_bell = 'Disabled'

-- Platform branching
local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_mac = wezterm.target_triple:find('darwin') ~= nil

if is_windows then
  -- Default shell: nu via Git Bash environment for path expectations.
  config.default_prog = { 'nu' }

  -- Right-click the new-tab button (or Ctrl+Shift+Space) for the shell picker.
  config.launch_menu = {
    { label = 'Nushell',     args = { 'nu' } },
    { label = 'Git Bash',    args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-l' } },
    { label = 'PowerShell 7', args = { 'pwsh.exe', '-NoLogo' } },
    { label = 'PowerShell 5', args = { 'powershell.exe', '-NoLogo' } },
    { label = 'cmd',         args = { 'cmd.exe' } },
  }
elseif is_mac then
  config.default_prog = { '/opt/homebrew/bin/nu' }
  config.launch_menu = {
    { label = 'Nushell', args = { '/opt/homebrew/bin/nu' } },
    { label = 'zsh',     args = { '/bin/zsh', '-l' } },
    { label = 'bash',    args = { '/bin/bash', '-l' } },
  }
else
  -- Linux
  config.default_prog = { '/home/linuxbrew/.linuxbrew/bin/nu' }
  config.launch_menu = {
    { label = 'Nushell', args = { '/home/linuxbrew/.linuxbrew/bin/nu' } },
    { label = 'bash',    args = { '/bin/bash', '-l' } },
  }
end

-- Keys
config.keys = {
  { key = ' ', mods = 'CTRL|SHIFT', action = wezterm.action.ShowLauncher },
  { key = 't', mods = 'CMD',        action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CMD',        action = wezterm.action.CloseCurrentTab { confirm = false } },
}

return config
