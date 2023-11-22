#!/bin/bash
# usage: autoplay.sh [PATH_TO_VIDEOs_DIR]
# The script will launch a tmux session and in each pane, will launch a ffmpeg command to play in loop a video file on a decklink SDI output (108050i)
# the directory containing the video files to play are provided as an argument.
# To monitor, open a terminal and attach to the tmux session (tmux a).
# NOTE: ffmpeg must be compiled manually beforehand because no binary including the decklink modules can be distributed

# Check if the directory path is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$1" ]; then
    echo "Directory does not exist"
    exit 1
fi

# decklink outputs (must be provided to ffmpeg with their id instead of strings like "Decklink (1)" because we cannot differentiate multiple cards this way
# Use 'ffmpeg -f decklink -sources' to get those ids
# Note: Two options here : either we provide the output devices manually, in chosen order, or we retrieve the ids automatically using an ffmpeg command
#output_devices=("81:b998d6b0:00000000", "81:b998d6b1:00000000", "81:b998d6b2:00000000", "81:b998d6b3:00000000", "81:9cce8950:00000000", "81:9cce8951:00000000", "81:9cce8952:00000000", "81:9cce8953:00000000", "81:a108a8c0:00000000", "81:a108a8c1:00000000", "81:a108a8c2:00000000", "81:a108a8c3:00000000")
output_devices=($(ffmpeg -hide_banner -f decklink -sources 2>/dev/null | grep DeckLink | awk {'print $1'}))

# Change to the provided directory
cd "$1" || exit 1

# Create a new session and window
tmux new-session -d -s "FFMPEG" -n "FFMPEG"

# Counter for accessing output devices elements
counter=0

# Select the first pane after creating the tmux session
tmux select-pane -t "FFMPEG:0"

# Loop through each video file in the directory
for video_file in *.mp4 *.mkv *.avi *.mxf *.MP4 *.MKV *.AVI *.MXF; do
    if [ -f "$video_file" ]; then
	      current_output="${output_devices[counter]}"

        # Split the window vertically except the first time
        if [ "$counter" -ne 0 ]; then
            tmux split-window -v -t "FFMPEG"
            tmux select-layout -t "FFMPEG" tiled
        fi
        
        tmux send-keys -t "FFMPEG" "ffmpeg -stream_loop -1 -i \"$video_file\" -s 1920x1080 -f decklink -format_code Hi50 -pix_fmt uyvy422 \"$current_output\"; read -p 'press enter to exit'; exit" Enter
	      ((counter++))

       # Break the loop if all output devices are used
        if [ $counter -eq ${#output_devices[@]} ]; then
            logger "WARNING: more video files than available decklink outputs"
	          break
        fi
    fi
done

# synchronize panes to control them all at the same time ('q' to end ffmpeg play)
tmux set-option -t "FFMPEG" synchronize-panes on

# Attach to the created tmux window
tmux attach-session -t "FFMPEG"
