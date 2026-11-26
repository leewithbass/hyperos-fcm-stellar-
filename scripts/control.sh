#!/system/bin/sh
BASE=/data/local/tmp/fcm-stellar
SRC="${0%/*}"
[ "$SRC" = "$0" ] && SRC=.
PIDFILE="$BASE/keepalive.pid"
running() {
 [ -f "$PIDFILE" ] || return 1
 PID=$(cat "$PIDFILE")
 case "$PID" in ''|*[!0-9]*) return 1;; esac
 kill -0 "$PID" 2>/dev/null && tr '\000' ' ' < "/proc/$PID/cmdline" 2>/dev/null | grep -q 'keepalive.sh'
}
case "$1" in
 start)
 mkdir -p "$BASE" || exit 1
 if running; then echo "Already running: $PID"; exit 0; fi
 rm -f "$PIDFILE"
 rmdir "$BASE/keepalive.lock" 2>/dev/null || true
 nohup sh "$SRC/keepalive.sh" "${2:-60}" </dev/null > "$BASE/keepalive.log" 2>&1 &
 echo "Started candidate PID $!; check status"
 ;;
 status)
 if running; then echo "RUNNING PID $PID"; else echo STOPPED; fi
 echo 'Last heartbeat:'; cat "$BASE/heartbeat" 2>/dev/null || true
 settings get system MILLET_NO_RESTRICT_APP
 cmd deviceidle whitelist | grep com.google.android.gms || true
 ;;
 stop)
 if running; then kill "$PID" && echo 'Stop signal sent'; else echo 'Not running'; fi
 ;;
 *) echo 'Usage: sh control.sh start|status|stop [seconds]' >&2; exit 2;;
esac
