#!/bin/sh
INTERVAL="${SCRAPE_INTERVAL:-60}"
OUT="/textfile_collector/battery.prom"

while :; do
  BAT="$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)"
  if [ -n "$BAT" ]; then
    CAP="$(cat "$BAT/capacity" 2>/dev/null || echo "")"
    STAT="$(cat "$BAT/status" 2>/dev/null || echo "Unknown")"
    if [ -n "$CAP" ]; then
      {
        echo "# HELP battery_capacity Battery charge percentage"
        echo "# TYPE battery_capacity gauge"
        echo "battery_capacity $CAP"
        echo "# HELP battery_status 0=Discharging,1=Charging,2=Unknown"
        echo "# TYPE battery_status gauge"
        case "$STAT" in
          Charging)   VAL=1 ;;
          Discharging) VAL=0 ;;
          *)          VAL=2 ;;
        esac
        echo "battery_status $VAL"
      } > "$OUT"
    fi
  fi
  sleep "$INTERVAL"
done