-- Discord-Widget: Unread-Zähler + Lauftext der letzten Nachrichten.
--
-- Zähler: Discord schreibt den Badge in den Fenstertitel:
--   "(N) Discord | …"  N Erwähnungen/ungelesene DMs
--   "• Discord | …"    ungelesen ohne Erwähnung
-- niri streamt jede Titeländerung, daher kein Polling. Ist Discord in den
-- Tray minimiert, gibt es kein Fenster und damit keinen Zähler.
--
-- Lauftext: Discords Desktop-Benachrichtigungen werden auf dem Session-Bus
-- mitgelesen (busctl monitor). Was dort landet, steuern Discords eigene
-- Benachrichtigungs-Einstellungen (pro Server "Nur @Erwähnungen").
-- Discord schickt keine Benachrichtigung, solange sein Fenster fokussiert ist.
-- Fokus auf Discord oder Rechtsklick leert den Lauftext.

-- ======== Einstellungen ==================================================
local MIN_WIDTH = 56 -- Mindestbreite des Widgets (px)
local TICKER_WIDTH = 280 -- Breite des Lauftexts (px)
local TICKER_CHARS = 40 -- sichtbare Zeichen im Lauftext
local MAX_MESSAGES = 5 -- so viele Nachrichten laufen durch
local MAX_BODY_CHARS = 120 -- längere Nachrichten werden gekürzt
local STEP_MS = 180 -- Scroll-Geschwindigkeit (ms pro Zeichen)

local DOT = "\u{2022}"
local SEP = "   " .. DOT .. "   "

-- ======== Zustand ========================================================
local windows = {} -- niri window id -> { count, dot, urgent }
local messages = {} -- neueste zuerst: { from, text }
local tickerChars = {} -- Lauftext als UTF-8-Zeichen
local tickerScrolls = false
local offset = 0

-- ======== Hilfsfunktionen ================================================
local function toChars(s)
  local chars = {}
  local ok = pcall(function()
    for _, cp in utf8.codes(s) do
      table.insert(chars, utf8.char(cp))
    end
  end)
  if not ok then -- kaputtes UTF-8: byteweise
    chars = {}
    for i = 1, #s do
      chars[i] = string.sub(s, i, i)
    end
  end
  return chars
end

local function truncate(s, n)
  local chars = toChars(s)
  if #chars <= n then
    return s
  end
  return table.concat(chars, "", 1, n - 1) .. "…"
end

local function clean(s)
  s = string.gsub(tostring(s or ""), "<[^>]*>", "")
  s = string.gsub(s, "%s+", " ")
  return noctalia.string.trim(s)
end

local function rebuildTicker()
  local parts = {}
  for _, m in ipairs(messages) do
    table.insert(parts, m.from ~= "" and (m.from .. ": " .. m.text) or m.text)
  end
  local full = table.concat(parts, SEP)
  tickerChars = toChars(full)
  tickerScrolls = #tickerChars > TICKER_CHARS
  if tickerScrolls then
    tickerChars = toChars(full .. SEP)
  end
  offset = 0
  noctalia.setUpdateInterval(tickerScrolls and STEP_MS or 60000)
end

local function tickerText()
  local n = #tickerChars
  if n == 0 then
    return nil
  end
  if not tickerScrolls then
    return table.concat(tickerChars)
  end
  local out = {}
  for i = 0, TICKER_CHARS - 1 do
    out[i + 1] = tickerChars[((offset + i) % n) + 1]
  end
  return table.concat(out)
end

local function clearMessages()
  if #messages > 0 then
    messages = {}
    rebuildTicker()
  end
end

-- ======== Darstellung ====================================================
local function render()
  local total, dot, running = 0, false, false
  for _, w in pairs(windows) do
    running = true
    total += w.count
    dot = dot or w.dot or w.urgent
  end

  local glyphColor = nil -- nil = Icon-Farbe des Widgets
  if total > 0 then
    glyphColor = "error"
  elseif dot or #messages > 0 then
    glyphColor = "primary"
  elseif not running then
    glyphColor = "outline"
  end

  local children = { ui.glyph({ name = "brand-discord", color = glyphColor }) }
  if total > 0 then
    table.insert(children, ui.label({ text = tostring(total), color = "error", fontWeight = "bold" }))
  elseif dot then
    table.insert(children, ui.label({ text = DOT, color = "primary" }))
  end

  local ticker = tickerText()
  if ticker then
    table.insert(children, ui.label({
      text = ticker,
      width = TICKER_WIDTH,
      maxWidth = TICKER_WIDTH,
      maxLines = 1,
      color = "on_surface_variant",
    }))
  end

  local tooltip
  if #messages > 0 then
    local lines = {}
    for _, m in ipairs(messages) do
      table.insert(lines, m.from .. ": " .. m.text)
    end
    tooltip = table.concat(lines, "\n")
  elseif total > 0 then
    tooltip = "Discord: " .. tostring(total) .. " ungelesen"
  elseif dot then
    tooltip = "Discord: neue Nachrichten"
  else
    tooltip = running and "Discord" or "Discord läuft nicht"
  end

  barWidget.render(ui.row({
    gap = 6,
    align = "center",
    justify = "center",
    minWidth = MIN_WIDTH,
    tooltip = tooltip,
  }, children))
end

-- ======== niri: Fenster, Titel, Fokus ====================================
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
  elseif ev.WindowFocusChanged and ev.WindowFocusChanged.id and windows[ev.WindowFocusChanged.id] then
    clearMessages() -- Discord angeschaut = gelesen
  else
    return
  end
  render()
end)

-- ======== Session-Bus: Discord-Benachrichtigungen ========================
-- Notify(app_name, replaces_id, icon, summary, body, actions, hints, timeout)
noctalia.runStream(
  "busctl --user monitor --json=short --match "
    .. "\"type='method_call',interface='org.freedesktop.Notifications',member='Notify'\"",
  function(line)
    local msg = noctalia.json.decode(line)
    if type(msg) ~= "table" or msg.member ~= "Notify" or type(msg.payload) ~= "table" then
      return
    end
    local d = msg.payload.data
    if type(d) ~= "table" or string.lower(tostring(d[1])) ~= "discord" then
      return
    end

    local from, text = clean(d[4]), truncate(clean(d[5]), MAX_BODY_CHARS)
    if from == "" and text == "" then
      return
    end
    table.insert(messages, 1, { from = from, text = text })
    while #messages > MAX_MESSAGES do
      table.remove(messages)
    end
    rebuildTicker()
    render()
  end
)

-- ======== Callbacks ======================================================
function update()
  if tickerScrolls then
    offset = (offset + 1) % #tickerChars
    render()
  end
end

-- Klick: Discord-Fenster fokussieren, sonst starten (Single-Instance
-- holt ein in den Tray minimiertes Discord wieder hervor).
function onClick()
  for id in pairs(windows) do
    noctalia.runAsync("niri msg action focus-window --id " .. tostring(id))
    return
  end
  noctalia.runAsync("discord")
end

-- Rechtsklick: Lauftext leeren.
function onRightClick()
  clearMessages()
  render()
end

noctalia.setUpdateInterval(60000)
render()
