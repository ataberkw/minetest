#!/bin/bash

# The directory to watch
WATCHED_DIR="/Users/ataberkw/dev/CPPProjects/minetest2"

# The Android directory to push to
ANDROID_DIR="/storage/emulated/0/Android/data/me.korata.finecraft/files/Minetest"

# The package name of the Android app
PACKAGE_NAME="me.korata.finecraft"

# Folders to include
INCLUDE_DIRS=(
    "builtin"
    "client"
    "fonts"
    "games"
    "locale"
    "textures"
)

INCLUDE_FILES=(
    "minetest.conf"
    "minetest_game.conf"
)

# Function to handle file changes
handle_file_change() {
    local changed_file_path="$1"
    local relative_path="${changed_file_path#$WATCHED_DIR/}"

    # Ensure the relative path does not start with a slash
    relative_path="${relative_path#/}"

    # Ignore .DS_Store files
    if [[ "$changed_file_path" == *".DS_Store"* ]]; then
        return 0
    fi

    # Check if the changed file is in the included directories
    local is_included_path=false
    for include_dir in "${INCLUDE_DIRS[@]}"; do
        if [[ "$relative_path" == "$include_dir/"* ]]; then
            is_included_path=true
            break
        fi
    done

    # Check if the changed file is in the included files
    if [ "$is_included_path" = false ]; then
        for include_file in "${INCLUDE_FILES[@]}"; do
            if [ "$relative_path" = "$include_file" ]; then
                is_included_path=true
                break
            fi
        done
    fi

    # If the file is not in the included directories, ignore it
    if [ "$is_included_path" = false ]; then
        return 0
    fi

    echo "File changed: $changed_file_path"

    # Stop the Android activity
    adb shell am force-stop "$PACKAGE_NAME"

    # Push the changed file to the Android device
    adb push "$changed_file_path" "$ANDROID_DIR/$relative_path"

    # Start the Android activity
    adb shell am start -n "$PACKAGE_NAME/.MainActivity"
}

# Start logcat in the background filtered by the package name
adb logcat --pid=$(adb shell pidof -s "$PACKAGE_NAME") > "${PACKAGE_NAME}_logcat.txt" 2>&1 &

echo "Logcat started for $PACKAGE_NAME and outputting to ${PACKAGE_NAME}_logcat.txt"

# Export the function so it can be used by the while loop
export -f handle_file_change

# Use fswatch to monitor the directory and handle changes, excluding .DS_Store files
fswatch -0 --exclude "\.DS_Store" "$WATCHED_DIR" | while IFS= read -r -d "" changed_file_path; do
    handle_file_change "$changed_file_path"
done
