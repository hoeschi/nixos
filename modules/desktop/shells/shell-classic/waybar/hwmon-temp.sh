# Temperatur per hwmon-Treibername auslesen.
#
# /sys/class/hwmon/hwmonN ist über Reboots hinweg nicht stabil, die
# Nummer hängt von der Probe-Reihenfolge der Treiber ab. Deshalb Suche
# nach dem Treibernamen statt festem Pfad.
# temp1_input: k10temp = Tctl, amdgpu = Edge.
#
# Aufruf: hwmon-temp.sh <treibername> <warn> <crit>

set -eu

want="$1"
warn="$2"
crit="$3"

for h in /sys/class/hwmon/hwmon*; do
  [ -r "$h/name" ] || continue
  read -r name < "$h/name"
  [ "$name" = "$want" ] || continue
  [ -r "$h/temp1_input" ] || continue

  read -r raw < "$h/temp1_input"
  t=$(( (raw + 500) / 1000 ))

  if   [ "$t" -ge "$crit" ]; then cls=critical
  elif [ "$t" -ge "$warn" ]; then cls=warning
  else                            cls=normal
  fi

  printf '{"text":"%s","class":"%s"}\n' "$t" "$cls"
  exit 0
done

printf '{"text":"--","class":"unknown"}\n'