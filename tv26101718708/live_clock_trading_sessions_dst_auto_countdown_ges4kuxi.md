# Live Clock + Trading Sessions | DST Auto | Countdown

- url: https://www.tradingview.com/script/geS4KuxI-Live-Clock-Trading-Sessions-DST-Auto-Countdown/
- type: indicator
- pine_id: PUB;d77277f65100480c8daa4ae183064662
- version: 1.0

## Description

A real-time clock, trading session detector, and bar countdown timer — all in one lightweight overlay. Designed for traders who need to track market hours across multiple time zones without switching tabs or doing mental math.

─────────────────────────────────────────
🕐 WHAT IT DOES
─────────────────────────────────────────

The indicator displays a compact information panel on your chart with up to two rows:

  Row 1 — Clock:    GMT: 14:32:07
  Row 2 — Countdown: Countdown: 12:44

The label on Row 1 switches automatically based on which mode you choose:

  • Timezone mode   →  shows your selected timezone prefix (e.g. "UTC: 14:32:07")
  • Session mode    →  shows the active trading session name (e.g. "London: 09:32:07")

─────────────────────────────────────────
📊 TRADING SESSION DETECTION
─────────────────────────────────────────

When set to Trading Session mode, the indicator automatically detects which Forex / equity session is currently open, using each exchange's local time:

  🔵 Sydney    — 10:00–19:00 AEST / AEDT
  🟠 Asia       — 09:00–18:00 JST  (Tokyo, no DST)
  🔵 London    — 08:00–17:00 GMT  / BST
  🟢 New York  — 09:30–17:00 EST  / EDT

When two sessions overlap, the label updates to reflect the combined window:

  🟡 London/NY     — the most liquid window of the trading day
  🟡 Asia/London   — early European session with Asian carry-over
  🟡 Tokyo/Sydney  — early Asian open overlap

When all sessions are closed, the panel shows "Off-Hours" in gray so you always know where you stand.

─────────────────────────────────────────
⏰ AUTOMATIC DAYLIGHT SAVING TIME (DST)
─────────────────────────────────────────

DST is handled entirely automatically — no manual adjustment, no seasonal settings to change.

The indicator uses IANA timezone identifiers (the same database your operating system uses) so that "8 AM London" always means 8 AM London time, whether the UK is on GMT (winter) or BST (summer). The same applies to New York (EST ↔ EDT) and Sydney (AEST ↔ AEDT). Tokyo has no DST and is always consistent.

You never need to touch a setting when clocks change.

─────────────────────────────────────────
⏱ BAR COUNTDOWN TIMER
─────────────────────────────────────────

A second row shows the exact time remaining until the current candle closes:

  • Short timeframes (< 1 hour):  MM:SS  →  e.g. Countdown: 12:44
  • Long timeframes  (≥ 1 hour):  H:MM:SS →  e.g. Countdown: 1:45:10

Works on every timeframe — 1m, 5m, 15m, 1h, 4h, Daily, and beyond. Can be toggled off if you prefer a single-row display.

─────────────────────────────────────────
⚙️ SETTINGS OVERVIEW
─────────────────────────────────────────

⏰ Clock
  • Label Mode         — "Timezone" or "Trading Session"
  • Timezone           — choose from 25 time zones (active in Timezone mode)
  • 24-Hour Format     — toggle 24h / 12h AM-PM display
  • Show Seconds       — show or hide the seconds digit
  • Show Date          — prepend the date (e.g. "03 Jun 2026  |  London: 09:32:07")
  • Show Countdown     — toggle the bar countdown row on or off

📊 Trading Sessions
  • Enable / disable each session individually (Sydney, Tokyo, London, New York)
  • Disabling a session removes it from detection and overlap logic entirely

🎨 Style
  • Position           — 8 placements: all four corners, top/bottom center, left/right middle
  • Background         — color and opacity
  • Text size          — Tiny / Small / Normal / Large / Huge
  • Clock color        — used in Timezone mode and for Off-Hours
  • Countdown color    — independent color for the countdown row
  • Per-session colors — assign a distinct color to each session and to overlaps
                         (defaults: Cyan = Sydney, Orange = Asia, Blue = London,
                          Green = New York, Yellow = any overlap, Gray = Off-Hours)

─────────────────────────────────────────
📌 HOW TO USE
─────────────────────────────────────────

1. Add the indicator to any chart via the Indicators menu.
2. Open Settings (⚙️ icon on the indicator) and choose your Label Mode.

  For Timezone mode:
    • Pick your local timezone from the Timezone dropdown.
    • The clock will always show the current time in that zone.

  For Trading Session mode:
    • No timezone selection needed — the clock automatically shows the
      local time of whatever session is currently open.
    • Colors change as sessions open and close, giving you an at-a-glance
      view of current market activity.

3. Adjust Position, size, and colors to suit your chart layout.
4. Toggle Show Countdown on or off depending on whether you track bar close timing.

─────────────────────────────────────────
💡 TIPS
─────────────────────────────────────────

  • The London/NY overlap (typically 13:00–17:00 UTC) highlights the highest-
    liquidity window of the Forex day — useful for breakout and momentum traders.

  • Pair with a clean chart layout: place the panel in a corner that does not
    overlap your price action or other indicators.

  • The countdown timer updates on each new tick, so it is most precise on
    liquid instruments (major Forex pairs, index futures, crypto).

  • The date row is useful on higher timeframes (4H, Daily) when you want
    to confirm the current session date across time zones.

## Source Code

````pine
//@version=5
indicator("🕐 Live Clock + Sessions", overlay=true, max_labels_count=0)

// ─── CLOCK INPUTS ─────────────────────────────────────────────
displayMode = input.string("Timezone", "Label Mode",
     options = ["Timezone", "Trading Session"],
     group   = "⏰ Clock",
     tooltip = "Timezone: uses your selected TZ prefix.\nTrading Session: auto-detects the open market, shows its local time. DST is fully automatic.")

tz = input.string("UTC", "Timezone  (used in Timezone mode)", options = ["UTC","GMT","US/Eastern","US/Central","US/Mountain","US/Pacific","America/New_York","America/Chicago","America/Denver","America/Los_Angeles", "America/Sao_Paulo","Europe/London","Europe/Paris","Europe/Berlin","Europe/Madrid","Europe/Rome","Europe/Moscow","Asia/Dubai","Asia/Kolkata","Asia/Singapore","Asia/Shanghai","Asia/Hong_Kong", "Asia/Tokyo","Asia/Seoul","Australia/Sydney","Pacific/Auckland"],
     group   = "⏰ Clock")

use24h        = input.bool(true,  "24-Hour Format",  group = "⏰ Clock")
showSeconds   = input.bool(true,  "Show Seconds",    group = "⏰ Clock")
showDate      = input.bool(false, "Show Date",       group = "⏰ Clock")
showCountdown = input.bool(true,  "Show Countdown",  group = "⏰ Clock")

// ─── SESSION INPUTS ───────────────────────────────────────────
// Ranges are each exchange's LOCAL time — DST shifts the UTC offset,
// but "8 AM London" is always "8 AM London" whether it's GMT or BST
showSydney = input.bool(true, "Sydney   · 10:00–19:00 AEST/AEDT  (DST auto)", group = "📊 Trading Sessions")
showTokyo  = input.bool(true, "Tokyo    · 09:00–18:00 JST  (no DST)",          group = "📊 Trading Sessions")
showLondon = input.bool(true, "London   · 08:00–17:00 GMT/BST  (DST auto)",    group = "📊 Trading Sessions")
showNY     = input.bool(true, "New York · 09:30–17:00 EST/EDT  (DST auto)",    group = "📊 Trading Sessions")

// ─── STYLE INPUTS ─────────────────────────────────────────────
pos = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Top Center","Bottom Center","Middle Right","Middle Left"],
     group   = "🎨 Style")
bgAlpha  = input.int(75, "Background Opacity %", 0, 100, group = "🎨 Style")
bgColor  = input.color(color.black,                "Background",          group = "🎨 Style")
txtColor = input.color(color.white,                "Clock Color (TZ mode / Off-Hours)", group = "🎨 Style")
cntColor = input.color(color.new(color.yellow, 0), "Countdown Color",     group = "🎨 Style")
txtSize  = input.string("Normal", "Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"],               group = "🎨 Style")

// Per-session colors — shown in Trading Session mode
colSydney = input.color(#00BCD4,                   "● Sydney Color",      group = "🎨 Style")  // cyan
colTokyo  = input.color(#FF8C00,                   "● Asia/Tokyo Color",  group = "🎨 Style")  // orange
colLondon = input.color(#2196F3,                   "● London Color",      group = "🎨 Style")  // blue
colNY     = input.color(#4CAF50,                   "● New York Color",    group = "🎨 Style")  // green
colOverlap= input.color(color.new(color.yellow, 0),"● Overlap Color",     group = "🎨 Style")  // yellow
colOff    = input.color(color.new(color.gray,  30),"● Off-Hours Color",   group = "🎨 Style")  // gray

// ─── FORMAT HELPER ────────────────────────────────────────────
pad(n) => n < 10 ? "0" + str.tostring(n) : str.tostring(n)

// ─── PRE-COMPUTE TIME IN ALL SESSION TIMEZONES ────────────────
// Pine Script resolves IANA TZ strings against its DST database on every tick
h_tz  = hour(timenow, tz)
m_tz  = minute(timenow, tz)
s_tz  = second(timenow, tz)

h_syd = hour(timenow,   "Australia/Sydney")
m_syd = minute(timenow, "Australia/Sydney")
s_syd = second(timenow, "Australia/Sydney")

h_tok = hour(timenow,   "Asia/Tokyo")
m_tok = minute(timenow, "Asia/Tokyo")
s_tok = second(timenow, "Asia/Tokyo")

h_lon = hour(timenow,   "Europe/London")
m_lon = minute(timenow, "Europe/London")
s_lon = second(timenow, "Europe/London")

h_ny  = hour(timenow,   "America/New_York")
m_ny  = minute(timenow, "America/New_York")
s_ny  = second(timenow, "America/New_York")

// ─── SESSION DETECTION ────────────────────────────────────────
t_syd = h_syd * 60 + m_syd
t_tok = h_tok * 60 + m_tok
t_lon = h_lon * 60 + m_lon
t_ny  = h_ny  * 60 + m_ny

syd_on = showSydney and t_syd >= 10*60      and t_syd < 19*60  // 10:00–19:00 AEST/AEDT
tok_on = showTokyo  and t_tok >= 9*60       and t_tok < 18*60  // 09:00–18:00 JST
lon_on = showLondon and t_lon >= 8*60       and t_lon < 17*60  // 08:00–17:00 GMT/BST
ny_on  = showNY     and t_ny  >= 9*60 + 30  and t_ny  < 17*60 // 09:30–17:00 EST/EDT

// ─── SESSION LABEL & COLOR ────────────────────────────────────
sesLabel = lon_on and ny_on  ? "London/NY"    :
           tok_on and lon_on ? "Asia/London"  :
           tok_on and syd_on ? "Tokyo/Sydney" :
           ny_on             ? "New York"     :
           lon_on            ? "London"       :
           tok_on            ? "Asia"         :
           syd_on            ? "Sydney"       : "Off-Hours"

sesColor = lon_on and ny_on  ? colOverlap :
           tok_on and lon_on ? colOverlap :
           tok_on and syd_on ? colOverlap :
           ny_on             ? colNY      :
           lon_on            ? colLondon  :
           tok_on            ? colTokyo   :
           syd_on            ? colSydney  : colOff

// ─── SELECT CLOCK VALUES ──────────────────────────────────────
// In Trading Session mode: time shown is the active session's local time
// In Timezone mode: time shown is from the user's selected TZ
eff_h = lon_on and ny_on  ? h_ny  : tok_on and lon_on ? h_lon : tok_on and syd_on ? h_tok : ny_on             ? h_ny  :lon_on            ? h_lon :tok_on            ? h_tok : syd_on            ? h_syd : h_tz

eff_m = lon_on and ny_on  ? m_ny  :  tok_on and lon_on ? m_lon : tok_on and syd_on ? m_tok :  ny_on             ? m_ny  :lon_on            ? m_lon :tok_on            ? m_tok : syd_on            ? m_syd : m_tz

eff_s = lon_on and ny_on  ? s_ny  :  tok_on and lon_on ? s_lon :  tok_on and syd_on ? s_tok :  ny_on             ? s_ny  :lon_on            ? s_lon : tok_on            ? s_tok :syd_on            ? s_syd : s_tz

isTSMode   = displayMode == "Trading Session"
disp_h     = isTSMode ? eff_h : h_tz
disp_m     = isTSMode ? eff_m : m_tz
disp_s     = isTSMode ? eff_s : s_tz
clockColor = isTSMode ? sesColor : txtColor
prefix     = isTSMode ? sesLabel : tz

// ─── CLOCK STRING ─────────────────────────────────────────────
h12  = disp_h == 0 ? 12 : disp_h > 12 ? disp_h - 12 : disp_h
ampm = disp_h < 12 ? " AM" : " PM"
hStr = use24h ? pad(disp_h) : str.tostring(h12)

timeStr = hStr + ":" + pad(disp_m) +
     (showSeconds ? ":" + pad(disp_s) : "") +
     (use24h ? "" : ampm)

dy     = dayofmonth(timenow, tz)
mo     = month(timenow, tz)
yr     = year(timenow, tz)
months = array.from("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
dateStr = pad(dy) + " " + array.get(months, mo - 1) + " " + str.tostring(yr) + "  |  "

clockStr = (showDate ? dateStr : "") + prefix + ": " + timeStr

// ─── COUNTDOWN STRING ─────────────────────────────────────────
remaining_ms = math.max(0, time_close - timenow)
total_secs   = int(math.floor(remaining_ms / 1000))
cnt_h        = int(total_secs / 3600)
cnt_m        = int((total_secs % 3600) / 60)
cnt_s        = int(total_secs % 60)

countdownStr = "Countdown: " +
     (cnt_h > 0
      ? str.tostring(cnt_h) + ":" + pad(cnt_m) + ":" + pad(cnt_s)
      : str.tostring(cnt_m) + ":" + pad(cnt_s))

// ─── TABLE POSITION & SIZE ────────────────────────────────────
tPos = switch pos
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Top Center"    => position.top_center
    "Bottom Center" => position.bottom_center
    "Middle Right"  => position.middle_right
    "Middle Left"   => position.middle_left
    =>                 position.top_right

tSize = switch txtSize
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge"  => size.huge
    =>         size.normal

// ─── TABLE ────────────────────────────────────────────────────
var table t = table.new(tPos, 1, 2,
     bgcolor      = color.new(bgColor, bgAlpha),
     border_color = color.new(color.gray, 60),
     border_width = 1,
     frame_color  = color.new(color.gray, 60),
     frame_width  = 1)

table.cell(t, 0, 0, clockStr,
     text_color  = clockColor,
     text_size   = tSize,
     text_halign = text.align_left)

table.cell(t, 0, 1,
     showCountdown ? countdownStr : "",
     text_color  = cntColor,
     text_size   = tSize,
     text_halign = text.align_left)
````
