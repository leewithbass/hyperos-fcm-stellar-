#!/system/bin/sh
BASE=/data/local/tmp/fcm-stellar
PIDFILE="$BASE/keepalive.pid"
LOCKDIR="$BASE/keepalive.lock"
INTERVAL="${1:-60}"
case "$INTERVAL" in ''|*[!0-9]*) exit 2;; esac
[ "$INTERVAL" -ge 30 ] || exit 2
mkdir -p "$BASE" || exit 1
mkdir "$LOCKDIR" 2>/dev/null || { echo 'Already running or stale lock'; exit 1; }
echo $$ > "$PIDFILE"
trap 'rm -f "$PIDFILE"; rmdir "$LOCKDIR" 2>/dev/null' 0
trap 'exit 0' 1 2 15
KEY=MILLET_NO_RESTRICT_APP
PKG=com.google.android.gms
while :; do
 if OLD=$(settings get system "$KEY"); then
 case ",$OLD," in *",$PKG,"*) ;; *)
 case "$OLD" in null|'') NEW="$PKG";; *) NEW="$OLD,$PKG";; esac
 settings put system "$KEY" "$NEW";; esac
 fi
 dumpsys greezer IM GMS disable >/dev/null
 dumpsys greezer LM add "$PKG" >/dev/null
 date '+%Y-%m-%d %H:%M:%S %z' > "$BASE/heartbeat"
 sleep "$INTERVAL" || exit 1
done
