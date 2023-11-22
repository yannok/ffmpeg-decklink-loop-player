# ffmpeg-decklink-loop-player
Bash script to play multiple video files in loop on Blackmagic Decklink outputs using ffmpeg

Usage: ./autoplay.sh [PATH_TO_VIDEOs_DIR]

This bash script will launch a tmux session and in each pane, will launch a ffmpeg command to play in loop a video file on a decklink SDI output (108050i).
The directory containing the video files are provided as an argument.

To monitor, open a terminal and attach to the tmux session (tmux a). All the panes are synchronized. To interrupt the playing, just press 'q'.

This was tested with 3x Decklink Duo 2 (4 SDI per card)

NOTES: 
- ffmpeg must be compiled manually beforehand because no binary including the decklink modules can be distributed
- ffmpeg command must be in the $PATH
- this script can be started at boot using crontab:
    @reboot /home/casparcg/autoplay.sh [PATH_TO_VIDEOS] 2>&1 | logger -t autoplay

    
