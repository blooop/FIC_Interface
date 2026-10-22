#!/usr/bin/env bash
# Every container start: the image's browser desktop, with no program open.
# Start the Studio from its taskbar, or with `fic studio` in a shell.
# Then open http://localhost:6081/vnc.html on the host.
set -euo pipefail

if pgrep -u "$(id -u)" -x Xtigervnc >/dev/null; then
    echo "The FIC desktop is already running."
    exit 0
fi

# The image's launch scripts and desktop entries come from docker/rootfs/ at
# the commit it was built from. Lay this checkout's copy over them, as the
# Dockerfile does, so a change there takes effect without a new image.
root="$(cd "$(dirname "$0")/.." && pwd)/docker/rootfs"
sudo cp -r --no-preserve=mode,ownership "${root}/." /
sudo chmod 0755 /usr/local/bin/fic /usr/local/bin/fic-*

export XDG_RUNTIME_DIR=/tmp/runtime-fic
mkdir -p "${ROS_LOG_DIR:-/tmp/ros_log}"

# setsid: the desktop must outlive the command devpod runs this from.
setsid nohup fic-session desktop >/tmp/fic-session.log 2>&1 </dev/null &
echo "The FIC desktop is starting: http://localhost:6081/vnc.html (log: /tmp/fic-session.log)"
