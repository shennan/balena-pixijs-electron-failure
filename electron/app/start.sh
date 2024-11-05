#!/bin/bash

# By default docker gives us 64MB of shared memory size but to display heavy
# pages we need more.
umount /dev/shm && mount -t tmpfs shm /dev/shm

# using local electron module instead of the global electron lets you
# easily control specific version dependency between your app and electron itself.
# the syntax below starts an X istance with ONLY our electronJS fired up,
# it saves you a LOT of resources avoiding full-desktops envs

rm /tmp/.X0-lock &>/dev/null || true

sleep 5; # Sleep to buffer the startup + restart sequence.

check_port() {
    host="$1"
    port="$2"

    while ! nc -z "$host" "$port"; do
        sleep 2
    done
}

declare -A orientations=( ["normal"]="'1 0 0 0 1 0 0 0 1" ["inverted"]="-1 0 1 0 -1 1 0 0 1" ["left"]="0 -1 1 1 0 0 0 0 1" ["right"]="0 1 0 -1 0 1 0 0 1")

cat > /usr/share/X11/xorg.conf.d/10-monitor.conf <<EOF
Section "Monitor"
    Identifier             "eDP1"
    Option		"Rotate"	"${SCREEN}"
EndSection
Section "Monitor"
    Identifier             "DP1"
    Option		"Rotate"	"${SCREEN}"
EndSection
Section "Monitor"
    Identifier             "DP2"
    Option		"Rotate"	"${SCREEN}"
EndSection
Section "Monitor"
    Identifier             "HDMI1"
    Option		"Rotate"	"${SCREEN}"
EndSection
Section "Monitor"
    Identifier             "HDMI2"
    Option		"Rotate"	"${SCREEN}"
EndSection

EOF

cat > /etc/X11/xorg.conf.d/90-rotate-screen.conf <<EOF

Section "InputClass"
    Identifier    "RotateTouch"
    Option    "TransformationMatrix" "${orientations[${SCREEN}]}"
    Driver "libinput"
EndSection

EOF

echo "DISPLAY:"
echo "$DISPLAY"

echo "GLX INFO:"
glxinfo

echo "SCREEN:"
echo "$SCREEN"

startx /usr/src/app/node_modules/electron/dist/electron --use-gl=egl /usr/src/app/ --enable-logging  --no-sandbox

amixer set Master on
amixer set Master 70%
