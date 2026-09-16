<!-- tradingview-pine-id: PUB;bbc8e74e94924274b026110862b177e3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Clock — Live / Replay Aware

Source: https://www.tradingview.com/script/rBb7j22L-Clock-Live-and-Replay-Aware/

## Description

Clock — Live / Replay Aware

A simple on-chart clock that always tells you the truth about what time it's showing — whether you're trading live or running Bar Replay.

Why this exists

Most clock indicators only show your real-world time, which becomes misleading (or useless) the moment you activate TradingView's Bar Replay feature — you end up staring at a clock that has nothing to do with the price action on screen. This indicator detects which mode you're in and adapts automatically.

Features

LIVE mode (green): Displays your actual real-time clock, synced to live incoming ticks.
REPLAY mode (orange): Displays the timestamp of the bar currently being replayed, so the clock always matches what you're watching, not your wall clock.

CHART mode (gray): Shown when you're simply scrolled through history with no live feed active.

Countdown timer: Shows time remaining until the next bar closes — exact in live mode, and estimated in replay mode using a rolling average of how long recent replayed bars have taken to form (adapts automatically if you change replay speed).
Configurable timezone, 12h/24h format, date display, table position, and colors.

How replay detection works

Pine Script has no official flag for "is Bar Replay active." This script uses a reliable heuristic instead: on a genuine live (still-forming) bar, its scheduled close time is always in the future relative to the current time. During replay, the bar being replayed is historical, so its close time has already passed. Comparing the two lets the script tell live and replay bars apart with no false positives in normal use.

Notes

The replay countdown is an estimate, not exact — replay speed isn't exposed to Pine Script, so it's inferred from recent bar timing and may lag by a bar or two after you change speeds.
Clock updates are tick-driven (a Pine Script constraint), so on very quiet symbols the seconds display may not tick with perfect real-time smoothness.

---

## Source Code

````pine
//@version=6
indicator("Clock — Live / Replay Aware", overlay=true)

// ─── Inputs ───────────────────────────────────────────────
posInput      = input.string("Top Right", "Table Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"])
tzInput       = input.string("", "Timezone (blank = exchange/chart default)",
     tooltip="Example: America/New_York, Etc/UTC, Europe/London")
show24h       = input.bool(true, "Use 24-hour format")
showDate      = input.bool(true, "Show date")
showSeconds   = input.bool(true, "Show seconds")
showCountdown = input.bool(true, "Show countdown to next bar")

colLive       = input.color(color.new(color.green, 0), "Live color")
colReplay     = input.color(color.new(color.orange, 0), "Replay color")
colHist       = input.color(color.new(color.gray, 0), "Historical color")
txtColor      = input.color(color.white, "Text color")

// ─── Position mapping ────────────────────────────────────
tablePos = posInput == "Top Left" ? position.top_left :
     posInput == "Top Right" ? position.top_right :
     posInput == "Bottom Left" ? position.bottom_left : position.bottom_right

// ─── Replay / live detection ─────────────────────────────
isReplay = barstate.isrealtime and time_close <= timenow
isLive   = barstate.isrealtime and time_close  > timenow

// ─── Build the time string ───────────────────────────────
tz = tzInput == "" ? syminfo.timezone : tzInput

fmt = (showDate ? "yyyy-MM-dd " : "") +
      (show24h ? "HH:mm" : "hh:mm") +
      (showSeconds ? ":ss" : "") +
      (show24h ? "" : " a")

refTime = isReplay ? time_close : isLive ? timenow : time_close
timeStr = str.format_time(refTime, fmt, tz)

label_ = isReplay ? "REPLAY" : isLive ? "LIVE" : "CHART"
bgCol  = isReplay ? colReplay : isLive ? colLive : colHist

// ─── Countdown to next bar ────────────────────────────────
var float replayBarStartWall = na
var float replayAvgDuration  = na

if isReplay and barstate.isnew
    replayBarStartWall := timenow

if isReplay and barstate.isconfirmed and not na(replayBarStartWall)
    float dur = timenow - replayBarStartWall
    replayAvgDuration := na(replayAvgDuration) ? dur : replayAvgDuration * 0.7 + dur * 0.3

pad2(n) => n < 10 ? "0" + str.tostring(n) : str.tostring(n)

f_fmtDuration(ms) =>
    totalSec = int(math.max(ms, 0) / 1000)
    h = totalSec / 3600
    m = (totalSec % 3600) / 60
    s = totalSec % 60
    h > 0 ? pad2(h) + ":" + pad2(m) + ":" + pad2(s) : pad2(m) + ":" + pad2(s)

countdownStr = isLive ? f_fmtDuration(time_close - timenow) :
     isReplay ? (na(replayAvgDuration) ? "calibrating…" :
          f_fmtDuration(math.max(replayAvgDuration - (timenow - replayBarStartWall), 0)) + " (est.)") :
     "n/a"

// ─── Draw table ───────────────────────────────────────────
rows = showCountdown ? 3 : 2
var table clock = table.new(tablePos, 1, rows, border_width=1)

if barstate.islast
    table.cell(clock, 0, 0, label_, bgcolor=bgCol, text_color=txtColor,
         text_size=size.small)
    table.cell(clock, 0, 1, timeStr, bgcolor=color.new(color.black, 20),
         text_color=txtColor, text_size=size.normal)
    if showCountdown
        table.cell(clock, 0, 2, "Next bar: " + countdownStr,
             bgcolor=color.new(color.black, 40), text_color=txtColor,
             text_size=size.small)
````
