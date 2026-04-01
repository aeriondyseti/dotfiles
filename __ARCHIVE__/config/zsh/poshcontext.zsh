# Oh My Posh context - called before each prompt render
# Workaround for https://github.com/JanDeDobbeleer/oh-my-posh/issues/7365

local sp_status artist track metadata
sp_status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
    string:org.mpris.MediaPlayer2.Player string:PlaybackStatus 2>/dev/null \
    | awk -F'"' '/string/{print tolower($2)}')
if [[ "$sp_status" == "playing" || "$sp_status" == "paused" ]]; then
    metadata=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
        /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
        string:org.mpris.MediaPlayer2.Player string:Metadata 2>/dev/null)
    artist=$(echo "$metadata" | awk -F'"' '/xesam:artist/{found=1; next} found && /string/{artists=artists sep $2; sep=", "} found && /\)/{print artists; exit}')
    track=$(echo "$metadata" | awk -F'"' '/xesam:title/{getline; print $2}')
    local icon=$'\uf04b'
    [[ "$sp_status" == "paused" ]] && icon=$'\uf04c'
    export SPOTIFY_NOW_PLAYING="$icon $artist - $track"
else
    export SPOTIFY_NOW_PLAYING=""
fi
