#!/usr/bin/env bash
## ---- 💫 https://github.com/JaKooLit 💫 (improved by GPT-5) ---- ##
# Wallpaper Selector for Hyprland (launch with SUPER+W)

# ----------------------------
# 🖼️ Configuration
# ----------------------------
wallpaperDir="$HOME/.config/walpapers/"   # Path to your wallpapers
themesDir="$HOME/.config/rofi/themes"

# swww transition settings
FPS=60
TYPE="any"
DURATION=3
BEZIER="0.4,0.2,0.4,1.0"
SWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"

# ----------------------------
# 🧹 Ensure swww is running
# ----------------------------
if command -v swww &>/dev/null; then
  if ! swww query &>/dev/null; then
    echo "[INFO] Starting swww daemon..."
    swww init
    sleep 1
  fi
fi

# ----------------------------
# 🎨 Collect all images
# ----------------------------
mapfile -d '' PICS < <(
  find -L "${wallpaperDir}" \
    -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.mp4' \) \
    -print0 | sort -z
)

if [[ ${#PICS[@]} -eq 0 ]]; then
  echo "No wallpapers found in ${wallpaperDir}"
  exit 1
fi

# Random wallpaper setup
randomNumber=$(( (RANDOM + $$ + $(date +%s)) % ${#PICS[@]} ))
randomPicture="${PICS[$randomNumber]}"
randomChoice="[${#PICS[@]}] Random Wallpaper"

# ----------------------------
# 🖱️ Rofi command
# ----------------------------
rofiCommand="rofi -dmenu -theme ${themesDir}/wallpaper-select.rasi"

# ----------------------------
# 🧠 Execute wallpaper change
# ----------------------------
executeCommand() {
  file="$1"
  ext=$(echo "${file##*.}" | tr '[:upper:]' '[:lower:]')

  # detect monitor
  monitor=$(hyprctl monitors | awk '/Monitor/{print $2; exit}')

  if [[ "$ext" == "mp4" || "$ext" == "gif" ]]; then
    if command -v mpvpaper &>/dev/null; then
      pkill mpvpaper 2>/dev/null
      mpvpaper -o "loop --no-audio" "$monitor" "$file" &
    else
      echo "mpvpaper not installed."
      exit 1
    fi

  else
    # stop video wallpaper if running
    pkill mpvpaper 2>/dev/null

    if command -v swww &>/dev/null; then
        swww img "$file" $SWWW_PARAMS
    elif command -v swaybg &>/dev/null; then
        swaybg -i "$file" &
    else
        echo "No wallpaper backend found."
        exit 1
    fi
  fi

  ln -sf "$file" "$HOME/.current_wallpaper"
  echo "✅ Wallpaper set: $(basename "$file")"
}

# ----------------------------
# 📜 Generate menu for Rofi
# ----------------------------
menu() {
  printf "%s\n" "$randomChoice"

  for img in "${PICS[@]}"; do
    filename="$(basename "$img")"
    printf "%s\x00icon\x1f%s\n" "$filename" "$img"
  done
}

# ----------------------------
# 🚀 Main Logic
# ----------------------------
main() {
  choice=$(menu | ${rofiCommand})

  [[ -z "$choice" ]] && exit 0

  if [[ "$choice" == "$randomChoice" ]]; then
    executeCommand "$randomPicture"
    exit 0
  fi

  for file in "${PICS[@]}"; do
    if [[ "$(basename "$file")" == "$choice" ]]; then
        selectedFile="$file"
        break
    fi
  done

  if [[ -n "$selectedFile" ]]; then
    executeCommand "$selectedFile"
  else
    echo "Image not found."
    exit 1
  fi
}

# Prevent multiple rofi instances
if pidof rofi &>/dev/null; then
  pkill rofi
  exit 0
fi

main
