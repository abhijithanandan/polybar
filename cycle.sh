#!/bin/bash

# Define the path to your Polybar launch script
LAUNCH_SCRIPT_DIR="$HOME/.config/polybar"
LAUNCH_SCRIPT_NAME="launch.sh"
LAUNCH_SCRIPT_PATH="${LAUNCH_SCRIPT_DIR}/${LAUNCH_SCRIPT_NAME}"

# Define the available themes based on your image
# These should be the exact flags your launch.sh expects
THEMES=(
    "--blocks"
    "--colorblocks"
    "--cuts"
    "--docky"
    "--forest"
    "--grayblocks"
    "--hack"
    "--material"
    "--panels"
    "--pwidgets"
    "--shades"
    "--shapes"
)

# State file to store the index of the current theme
# Using a directory that should exist and be user-writable
STATE_DIR="$HOME/.local/state/polybar_theme_cycler"
STATE_FILE="${STATE_DIR}/current_theme_index"

# Create state directory if it doesn't exist
mkdir -p "$STATE_DIR"

# Get the number of themes
NUM_THEMES=${#THEMES[@]}

# Read the last used theme index
CURRENT_INDEX=-1 # Default to -1 so that the first theme (index 0) is chosen on the first run
if [[ -f "$STATE_FILE" ]]; then
    CURRENT_INDEX=$(cat "$STATE_FILE")
    # Validate if the index is a number and within bounds
    if ! [[ "$CURRENT_INDEX" =~ ^[0-9]+$ ]] || (( CURRENT_INDEX < 0 || CURRENT_INDEX >= NUM_THEMES )); then
        echo "Warning: Invalid index found in state file. Resetting to first theme."
        CURRENT_INDEX=-1
    fi
fi

# Calculate the next theme index
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % NUM_THEMES ))

# Get the next theme
NEXT_THEME=${THEMES[$NEXT_INDEX]}

echo "Switching to Polybar theme: $NEXT_THEME"

# Launch Polybar with the new theme
# Make sure launch.sh is executable and handles killing existing instances
if [[ -x "$LAUNCH_SCRIPT_PATH" ]]; then
    # Go to the directory of launch.sh if it requires to be run from there
    # Some scripts rely on relative paths
    (cd "$LAUNCH_SCRIPT_DIR" && "./$LAUNCH_SCRIPT_NAME" "$NEXT_THEME")
else
    echo "Error: Launch script not found or not executable at $LAUNCH_SCRIPT_PATH"
    exit 1
fi

# Save the new theme index to the state file
echo "$NEXT_INDEX" > "$STATE_FILE"

echo "Theme switched. Current index $NEXT_INDEX saved."
