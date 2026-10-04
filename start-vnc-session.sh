#!/bin/bash

# see https://en.wikipedia.org/wiki/Xvfb#Remote_control_over_SSH

DISPLAY_NAME="${DISPLAY:-:0}"
DISP_NUM="${DISPLAY_NAME#:}"
DISP_NUM="${DISP_NUM:-0}"
export DISPLAY=":${DISP_NUM}"

if [ -e "/tmp/.X${DISP_NUM}-lock" ]; then
    echo "A VNC session is already running on display :${DISP_NUM}."
    exit 0
fi

Xvfb :"${DISP_NUM}" -screen 0 "${CUSTOM_XVFB_WxHxD:=1200x800x16}" -ac -pn -noreset &

${WINDOW_MANAGER} &

VNC_PORT=$((5900 + DISP_NUM))
NOVNC_PORT=$((6080 + DISP_NUM))

x11vnc -localhost -shared -display :"${DISP_NUM}" -forever -rfbport "${VNC_PORT}" -bg -o "/tmp/x11vnc-${DISP_NUM}.log"
cd /opt/novnc/utils && ./novnc_proxy --vnc "localhost:${VNC_PORT}" --listen "${NOVNC_PORT}" &
