-- WezTerm cross-platform config.
-- Symlinked to ~/.wezterm.lua on Mac/Linux, %USERPROFILE%\.wezterm.lua on Windows.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 13.0
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }
config.use_fancy_tab_bar = false
config.scrollback_lines = 50000
config.audible_bell = 'Disabled'

-- Background: Sombra hacking skull (Overwatch, 2016 ARG era).
-- Image lives in the dotfiles repo so it's the same across hosts.
local function dotfiles_dir()
  if wezterm.target_triple:find('windows') then
    return wezterm.home_dir .. '\\projects-x\\coilysiren\\dotfiles'
  end
  return wezterm.home_dir .. '/projects/coilysiren/dotfiles'
end
config.background = {
  {
    source = { File = dotfiles_dir() .. '/static/wallpaper.jpg' },
    hsb = { brightness = 0.08, saturation = 0.7 },
    width = 'Cover',
    height = 'Cover',
    horizontal_align = 'Center',
    vertical_align = 'Middle',
  },
}

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
else
  -- Resolve nu against the candidate paths brew/cargo/linuxbrew put it at.
  local function find_nu()
    local candidates = {
      '/opt/homebrew/bin/nu',
      '/usr/local/bin/nu',
      wezterm.home_dir .. '/.cargo/bin/nu',
      '/home/linuxbrew/.linuxbrew/bin/nu',
    }
    for _, p in ipairs(candidates) do
      local f = io.open(p, 'r')
      if f then f:close() return p end
    end
    return 'nu'
  end
  local nu = find_nu()
  config.default_prog = { nu }
  if is_mac then
    config.launch_menu = {
      { label = 'Nushell', args = { nu } },
      { label = 'zsh',     args = { '/bin/zsh', '-l' } },
      { label = 'bash',    args = { '/bin/bash', '-l' } },
    }
  else
    config.launch_menu = {
      { label = 'Nushell', args = { nu } },
      { label = 'bash',    args = { '/bin/bash', '-l' } },
    }
  end
end

-- Keys
config.keys = {
  { key = ' ', mods = 'CTRL|SHIFT', action = wezterm.action.ShowLauncher },
  { key = 't', mods = 'CMD',        action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CMD',        action = wezterm.action.CloseCurrentTab { confirm = false } },
}

return config
