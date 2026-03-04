-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28
config.window_decorations = 'RESIZE'

config.window_padding = {
  left = 30,
  right = 30,
  top = 30,
  bottom = 10,
}

-- or, changing the font size and color scheme.
config.enable_tab_bar = false
config.font = wezterm.font 'MesloLgs Nerd Font Mono'
config.font_size = 14
config.color_scheme = 'Catppuccin Mocha'


-- Finally, return the configuration to wezterm:
return config