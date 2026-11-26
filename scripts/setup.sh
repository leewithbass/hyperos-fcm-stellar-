#!/system/bin/sh
PKG=com.google.android.gms
KEY=MILLET_NO_RESTRICT_APP
run() { "$@" && echo "[OK] $*" || echo "[WARN] Unsupported or denied: $*"; }
[ "$(id -u)" = 2000 ] || echo '[WARN] Expected shell UID 2000'
run cmd deviceidle whitelist +"$PKG"
run cmd appops set "$PKG" RUN_IN_BACKGROUND allow
run cmd appops set "$PKG" RUN_ANY_IN_BACKGROUND allow
run cmd appops set "$PKG" WAKE_LOCK allow
run am set-inactive "$PKG" false
run am set-standby-bucket "$PKG" active
UID_GMS=$(pm list packages -U --user 0 "$PKG" | sed -n "s/^package:$PKG uid://p" | head -n 1)
[ -n "$UID_GMS" ] && run cmd netpolicy add restrict-background-whitelist "$UID_GMS"
OLD=$(settings get system "$KEY") || exit 1
case ",$OLD," in *",$PKG,"*) ;; *)
 case "$OLD" in null|'') NEW="$PKG";; *) NEW="$OLD,$PKG";; esac
 run settings put system "$KEY" "$NEW";; esac
run dumpsys greezer IM GMS disable
run dumpsys greezer LM add "$PKG"
echo '[INFO] OEM commands are undocumented; verify on device.'
