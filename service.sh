#!/system/bin/sh

PREF=9000
TABLE=tun0
LOG=/data/local/tmp/vpn-tun0-rule-fix.log
IP=/system/bin/ip
LAST_STATE=

[ -x "$IP" ] || IP=ip

log_msg() {
  echo "$(date '+%F %T') $*" >> "$LOG"
}

rule_exists() {
  "$IP" rule | grep -q "${PREF}:.*lookup ${TABLE}"
}

add_rule() {
  if ! rule_exists; then
    if "$IP" rule add pref "$PREF" lookup "$TABLE"; then
      "$IP" route flush cache
      log_msg "added rule: pref $PREF lookup $TABLE"
    else
      log_msg "failed to add rule: pref $PREF lookup $TABLE"
    fi
  fi
}

delete_rule() {
  while rule_exists; do
    if "$IP" rule del pref "$PREF" lookup "$TABLE"; then
      "$IP" route flush cache
      log_msg "removed rule: pref $PREF lookup $TABLE"
    else
      log_msg "failed to remove rule: pref $PREF lookup $TABLE"
      break
    fi
  done
}

system_ready() {
  [ "$(getprop sys.boot_completed)" = "1" ]
}

tun0_ready() {
  [ -d "/sys/class/net/$TABLE" ] && "$IP" route show table "$TABLE" | grep -q .
}

set_state() {
  if [ "$LAST_STATE" != "$1" ]; then
    LAST_STATE="$1"
    log_msg "$1"
  fi
}

while ! system_ready; do
  sleep 5
done

log_msg "service started"
log_msg "ip command: $IP"

while true; do
  if tun0_ready; then
    set_state "$TABLE ready"
    add_rule
  else
    set_state "waiting for $TABLE routes"
    delete_rule
  fi

  sleep 5
done
