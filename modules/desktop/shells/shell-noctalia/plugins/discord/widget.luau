-- Discord schreibt den Badge in den Fenstertitel:
--   "(N) Discord | …"  N Erwähnungen/ungelesene DMs
--   "• Discord | …"    ungelesen ohne Erwähnung
-- niri streamt jede Titeländerung, daher kein Polling.
-- Einschränkung: Ist Discord in den Tray minimiert, gibt es kein Fenster
-- und damit keinen Zähler.
local DOT = "\u{2022}"
local windows = {} -- niri window id -> { count, dot, urgent }

local function track(w)
  if w.app_id ~= "discord" then
    windows[w.id] = nil
    return
  end
  local title = w.title or ""
  local n = tonumber(string.match(title, "^%((%d+)%)") or "0")
  windows[w.id] = {
    count = n,
    dot = string.sub(title, 1, #DOT) == DOT,
    urgent = w.is_urgent == true,
  }
end

local function render()
  local total, dot, running = 0, false, false
  for _, w in pairs(windows) do
    running = true
    total += w.count
    dot = dot or w.dot or w.urgent
  end

  barWidget.setGlyph("brand-discord")
  if total > 0 then
    barWidget.setText(tostring(total))
    barWidget.setColor("error")
    barWidget.setGlyphColor("error")
    barWidget.setTooltip({ "Discord", tostring(total) .. " ungelesen" })
  elseif dot then
    barWidget.setText(DOT)
    barWidget.setColor("primary")
    barWidget.setGlyphColor("primary")
    barWidget.setTooltip({ "Discord", "neue Nachrichten" })
  else
    barWidget.setText("")
    barWidget.setGlyphColor(running and "on_surface" or "outline")
    barWidget.setTooltip(running and "Discord" or "Discord läuft nicht")
  end
end

noctalia.runStream("niri msg --json event-stream", function(line)
  local ev = noctalia.json.decode(line)
  if type(ev) ~= "table" then
    return
  end

  if ev.WindowsChanged then
    windows = {}
    for _, w in ipairs(ev.WindowsChanged.windows) do
      track(w)
    end
  elseif ev.WindowOpenedOrChanged then
    track(ev.WindowOpenedOrChanged.window)
  elseif ev.WindowClosed then
    windows[ev.WindowClosed.id] = nil
  elseif ev.WindowUrgencyChanged and windows[ev.WindowUrgencyChanged.id] then
    windows[ev.WindowUrgencyChanged.id].urgent = ev.WindowUrgencyChanged.urgent == true
  else
    return
  end
  render()
end)

-- Klick: Discord-Fenster fokussieren, sonst starten (Single-Instance
-- holt ein in den Tray minimiertes Discord wieder hervor).
function onClick()
  for id in pairs(windows) do
    noctalia.runAsync("niri msg action focus-window --id " .. tostring(id))
    return
  end
  noctalia.runAsync("discord")
end

render()
