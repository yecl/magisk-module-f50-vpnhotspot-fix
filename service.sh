#!/system/bin/sh

PREF=9000
TABLE=tun0
LOG=/data/local/tmp/vpn-tun0-rule-fix.log

log_msg() {
  echo "$(date '+%F %T') $*" >> "$LOG"
}

rule_exists() {
  ip rule | grep -q "${PREF}:.*lookup ${TABLE}"
}

add_rule() {
  if ! rule_exists; then
    if ip rule add pref "$PREF" lookup "$TABLE"; then
      ip route flush cache
      log_msg "added rule: pref $PREF lookup $TABLE"
    else
      log_msg "failed to add rule: pref $PREF lookup $TABLE"
    fi
  fi
}

delete_rule() {
  while rule_exists; do
    if ip rule del pref "$PREF" lookup "$TABLE"; then
      ip route flush cache
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
  ip link show "$TABLE" >/dev/null 2>&1 && ip route show table "$TABLE" | grep -q .
}

while ! system_ready; do
  sleep 5
done

log_msg "service started"

while true; do
  if tun0_ready; then
    add_rule
  else
    delete_rule
  fi

  sleep 5
done

