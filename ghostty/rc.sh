theme = Rose Pine
# theme = Rose Pine Dawn

custom-shader = ./shaders/cursor-blaze.glsl
# custom-shader = ./shaders/starfield.glsl
# custom-shader = ./shaders/drunkard.glsl
# custom-shader = ./shaders/matrix.glsl
# custom-shader = ./shaders/retro-terminal.glsl
# custom-shader = ./shaders/water.glsl

# background-opacity = 0.9
# background-blur-radius = 10

clipboard-paste-protection = false
window-save-state = always

# Splitting
keybind = ctrl+space>r=reload_config
keybind = ctrl+space>shift+\=new_split:right
keybind = ctrl+space>-=new_split:down
keybind = ctrl+space>t=toggle_quick_terminal

# Moving focus
keybind = option+h=goto_split:left
keybind = option+j=goto_split:down
keybind = option+k=goto_split:up
keybind = option+l=goto_split:right

# Layout / Zoom
keybind = ctrl+space>e=equalize_splits
keybind = ctrl+space>enter=toggle_split_zoom
keybind = shift+enter=text:\x1b\r
