#!/bin/bash

# Wait until at least one output is active
while [[ $(hyprctl activeoutputs | wc -l) -eq 0 ]]; do
    sleep 0.2
done

# Optional extra delay to be safe
sleep 0.5

# Apply warm shader
hyprshade on ~/.config/hyprshade/shaders/warm.glsl

