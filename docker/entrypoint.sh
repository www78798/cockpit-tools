#!/usr/bin/env bash
set -Eeuo pipefail

export DISPLAY="${DISPLAY:-:0}"
export HOME="${HOME:-/home/cockpit}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/xdg-runtime-cockpit}"
mkdir -p "$XDG_RUNTIME_DIR" "$HOME/.cockpit_tools"
chmod 700 "$XDG_RUNTIME_DIR"

# Start a private session bus and Secret Service. Credentials stay in the
# persistent container volume, not in the Windows host credential store.
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  eval "$(dbus-launch --sh-syntax)"
fi
if command -v gnome-keyring-daemon >/dev/null 2>&1; then
  eval "$(gnome-keyring-daemon --start --components=secrets 2>/dev/null)" || true
fi

Xvfb "$DISPLAY" -screen 0 "${SCREEN_SIZE:-1600x1000x24}" -ac +extension GLX +render -noreset &
XVFB_PID=$!
openbox --sm-disable >/tmp/openbox.log 2>&1 &
OPENBOX_PID=$!

VNC_PID=""
NOVNC_PID=""
APP_PID=""
cleanup() {
  [[ -n "$APP_PID" ]] && kill "$APP_PID" 2>/dev/null || true
  [[ -n "$NOVNC_PID" ]] && kill "$NOVNC_PID" 2>/dev/null || true
  [[ -n "$VNC_PID" ]] && kill "$VNC_PID" 2>/dev/null || true
  kill "$OPENBOX_PID" "$XVFB_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

for _ in $(seq 1 50); do
  if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done
xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 || {
  echo "Xvfb did not become ready" >&2
  exit 1
}

x11vnc -display "$DISPLAY" -forever -shared -rfbport 5900 -localhost -nopw -xkb -noxdamage >/tmp/x11vnc.log 2>&1 &
VNC_PID=$!
websockify --web=/usr/share/novnc "${NOVNC_PORT:-6080}" 127.0.0.1:5900 >/tmp/novnc.log 2>&1 &
NOVNC_PID=$!

echo "Starting Cockpit Tools desktop; open http://localhost:${NOVNC_PORT:-6080}/vnc.html?autoconnect=true"
cockpit-tools &
APP_PID=$!
wait "$APP_PID"
