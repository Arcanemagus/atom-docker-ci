#!/bin/bash
PIDFILE=/tmp/xvfb_${DISPLAY:1}.pid
XVFB="/usr/bin/Xvfb"
XVFBARGS="${DISPLAY} -ac -screen 0 1024x768x16 +extension RANDR"

/sbin/start-stop-daemon --start --quiet --background \
  --pidfile $PIDFILE --make-pidfile \
  --exec $XVFB -- $XVFBARGS

exec "$@"
