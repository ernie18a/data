# Fix PIPS - 4 Sessions - FRA / LDN / NY / ASIA

- url: https://www.tradingview.com/script/sOSZXJLH-Fix-PIPS-4-Sessions-FRA-LDN-NY-ASIA/
- type: indicator
- pine_id: PUB;24731510bb214827b2ce412d87c42194
- version: 5.0

## Description

4 Sessions draws High/Low range boxes for the four major market sessions — Frankfurt, London, New York and Tokyo.

HOW IT WORKS
Each session is a translucent box that tracks the session's running High/Low as it develops. Session hours are defined in each market's home timezone (Europe/Berlin, Europe/London, America/New_York, Asia/Tokyo), so the boxes always land in the right place regardless of your chart's timezone, and DST transitions in every region are handled automatically — nothing to adjust twice a year.

DEFAULT HOURS (exchange hours, editable)
• Frankfurt — 08:00–09:00 (Xetra open, the hour before London)
• London — 08:00–16:30
• New York — 09:30–16:00 (NYSE)
• Tokyo — 09:00–15:00 (TSE)

SETTINGS
One row per session: enable toggle, color (set fill opacity right in the color picker) and hours. Weekdays only — no weekend boxes on 24/7 markets like crypto. Works on intraday timeframes. Optional on-chart info note with a UA/EN/RU language switch.

ALERTS
Alert conditions fire on each session open (Frankfurt, London, New York, Asia).

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
//  4 SESSIONS — Frankfurt · London · New York · Asia
//  Simple session boxes (High/Low range). Each session runs in its own
//  home timezone, so DST is handled automatically via IANA zones.
// ════════════════════════════════════════════════════════════════════
indicator("4 Sessions - FRA / LDN / NY / ASIA", "4 Sessions",
     overlay = true, max_boxes_count = 500)

// ─────────────────────────── SESSIONS ───────────────────────────────
// One row per session: enable · color · hours (in the session's home tz).
gF   = "① Frankfurt (CET/CEST)"
fOn  = input.bool(true, "", inline = "f", group = gF, display = display.none)
fC   = input.color(color.new(#7e57c2, 90), "", inline = "f", group = gF)
fSes = input.session("0800-0900", "", inline = "f", group = gF, display = display.none)  // Xetra open, hour before London
fTz  = "Europe/Berlin"

gL   = "② London (GMT/BST)"
lOn  = input.bool(true, "", inline = "l", group = gL, display = display.none)
lC   = input.color(color.new(#66bb6a, 90), "", inline = "l", group = gL)
lSes = input.session("0800-1630", "", inline = "l", group = gL, display = display.none)
lTz  = "Europe/London"

gN   = "③ New York (EST/EDT)"
nOn  = input.bool(true, "", inline = "n", group = gN, display = display.none)
nC   = input.color(color.new(#ffa726, 90), "", inline = "n", group = gN)
nSes = input.session("0930-1600", "", inline = "n", group = gN, display = display.none)  // NYSE hours
nTz  = "America/New_York"

gA   = "④ Asia / Tokyo (JST)"
aOn  = input.bool(true, "", inline = "a", group = gA, display = display.none)
aC   = input.color(color.new(#2962ff, 90), "", inline = "a", group = gA)
aSes = input.session("0900-1800", "", inline = "a", group = gA, display = display.none)  // Tokyo open → trimmed at Frankfurt open
aTz  = "Asia/Tokyo"

// ─────────────────────────── HELPERS ────────────────────────────────
// ":23456" = weekdays Mon–Fri (Pine day-of-week: 1 = Sunday … 7 = Saturday)
WD = ":23456"

// Draws one session. var state is unique per call site,
// so 4 calls = 4 independent sessions.
drawSession(bool inNow, color col) =>
    var box   bx  = na
    var float hi  = na
    var float lo  = na
    var bool  act = false
    // A bar's `time` is its LEFT edge (open time). Draw the box from the left
    // edge of the first bar (time) to the right edge of the last bar (time +
    // one bar). This fills the edge candles fully AND lets adjacent sessions
    // meet edge-to-edge with no gap and no overlap.
    int barMs = timeframe.in_seconds() * 1000
    if inNow and not act                          // session just opened
        hi  := high
        lo  := low
        act := true
        bx  := box.new(time, high, time + barMs, low,
             xloc = xloc.bar_time,
             border_color = color.new(col, 100), border_width = 1,
             bgcolor = col)
    else if inNow and act                         // inside the session — update
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        if not na(bx)
            box.set_top(bx, hi)
            box.set_bottom(bx, lo)
            box.set_right(bx, time + barMs)
    else if not inNow and act                     // session closed
        act := false
    act                                           // unified return type (unused)

// ─────────────────────────── LOGIC ──────────────────────────────────
intra = timeframe.isintraday
inF = intra and fOn and not na(time(timeframe.period, fSes + WD, fTz))
inL = intra and lOn and not na(time(timeframe.period, lSes + WD, lTz))
inN = intra and nOn and not na(time(timeframe.period, nSes + WD, nTz))

// Asia runs from the Tokyo open until the moment Frankfurt opens, with no DST
// gap or overlap between the two. Tokyo has no DST but Frankfurt does, so we
// can't hard-code the Asian close in JST (it would drift by an hour each half
// of the year). Instead the cut-off is anchored to Frankfurt's own timezone:
// the Asia box stops as soon as the European day begins (Frankfurt's open hour
// through end of day), which auto-follows DST.
fStart = str.substring(fSes, 0, 4)                                   // "0800" from "0800-0900"
euOpen = not na(time(timeframe.period, fStart + "-2359" + WD, fTz)) // European day has begun
inA = intra and aOn and not na(time(timeframe.period, aSes + WD, aTz)) and not euOpen

drawSession(inF, fC)
drawSession(inL, lC)
drawSession(inN, nC)
drawSession(inA, aC)

// ─────────────────────────── ALERTS ─────────────────────────────────
alertcondition(inF and not inF[1], "Frankfurt open", "Frankfurt session opened")
alertcondition(inL and not inL[1], "London open",    "London session opened")
alertcondition(inN and not inN[1], "New York open",  "New York session opened")
alertcondition(inA and not inA[1], "Asia open",      "Asia session opened")
````
