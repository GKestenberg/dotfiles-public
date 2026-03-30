#!/bin/sh

current_layout=$(yabai -m config layout)
if [ "$current_layout" = "bsp" ]; then
    yabai -m config layout float
else
    yabai -m config layout bsp
fi
