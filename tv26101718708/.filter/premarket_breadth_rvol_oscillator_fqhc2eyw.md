# Pre-Market Breadth & RVOL Oscillator

- url: https://www.tradingview.com/script/fqHC2eyw-Pre-Market-Breadth-RVOL-Oscillator/
- type: indicator
- pine_id: PUB;59aeaf391eaa4627a92d20d8f0650327
- version: 4.0

## Description

Pre-Market Breadth & RVOL Oscillator

This indicator answers two questions traders ask before the New York cash open at 9:30 ET: is real volume showing up, and is the tape actually broad-based, or is this just noise?

What it shows

RVOL (Relative Volume) — plots today's cumulative volume against the average cumulative volume at the same minute-of-day over the last N sessions (default 10, adjustable). A reading of 1.0 means volume is tracking normal. Above the "Elevated" line (default 1.5x) signals unusually strong participation; above "Heavy" (default 2.0x) signals a session that's meaningfully outpacing its recent average — the kind of volume that tends to accompany moves with follow-through rather than fade.
NYSE TICK — the number of NYSE-listed stocks trading on an uptick minus those on a downtick, recalculated essentially every trade. It's a real-time gauge of order-flow pressure; sharp spikes toward the extremes often mark short-term buying or selling exhaustion.
NYSE ADD (Advance/Decline) — the count of advancing stocks minus declining stocks, running cumulative through the session. Unlike TICK, this measures breadth: whether a move is being carried by the broad market or just a handful of large-cap names.

Used together, these three answer different pieces of the same question — RVOL tells you if volume is real, TICK tells you the moment-to-moment pressure, and ADD tells you how many stocks are actually participating.

Settings

Fully adjustable RVOL lookback window and threshold levels, with color/width customization
TICK and ADD symbols, source (open/high/low/close), display toggles, and colors — all configurable
Exchange timezone dropdown (defaults to America/New_York) so the minute-of-day calculation aligns correctly with your target session
Optional pre-market session highlight with adjustable start/end time and color

How to use it

Best viewed on a 1-minute chart in the pre-market or early session window. Look for RVOL breaking above 1.5x alongside TICK/ADD moving in a consistent direction — that combination suggests a session with real conviction behind it, as opposed to a low-volume drift that's more likely to reverse once the cash session brings in full liquidity.

## Source Code

````pine
//@version=6
indicator("Pre-Market Breadth & RVOL Oscillator", overlay = false)
// ============================================================
// BREADTH & RVOL OSCILLATOR
// - RVOL: today's cumulative volume vs the N-day average
//   cumulative volume at the same minute-of-day (best on a
//   1-minute chart; matches "is this real volume" question).
// - NYSE TICK and ADD plotted alongside for breadth confirmation.
// Pair this with "Pre-Market Cross-Asset Dashboard" (overlay table).
// All defaults below match the original version exactly.
// ============================================================

// ---------- RVOL SETTINGS ----------
grpRvol = "RVOL Settings"
lookbackDays   = input.int(10, "Days for RVOL average", minval = 2, maxval = 20, group = grpRvol)
rvolSource     = input.source(volume, "RVOL Source", group = grpRvol)
rvolElevated   = input.float(1.5, "Elevated threshold (x avg)", minval = 1.0, step = 0.1, group = grpRvol)
rvolHeavy      = input.float(2.0, "Heavy threshold (x avg)", minval = 1.0, step = 0.1, group = grpRvol)
showRvolLines  = input.bool(true, "Show threshold lines", group = grpRvol)
rvolColor      = input.color(color.aqua, "RVOL line color", group = grpRvol)
rvolWidth      = input.int(2, "RVOL line width", minval = 1, maxval = 4, group = grpRvol)

// ---------- ADDITIONAL INSTRUMENT RVOL ----------
grpExtra = "Additional Instrument RVOL"
dxySym   = input.symbol("ICEUS:DX1!", "DXY Futures", group = grpExtra)
us10ySym = input.symbol("TVC:US10Y", "US 10Y Yield (note: cash index, may have no volume)", group = grpExtra)
zbSym    = input.symbol("CBOT:ZB1!", "30Y Bond Futures (ZB)", group = grpExtra)
showDxyRvol   = input.bool(true, "Show DXY RVOL", group = grpExtra)
showUs10yRvol = input.bool(true, "Show US10Y RVOL", group = grpExtra)
showZbRvol    = input.bool(true, "Show ZB RVOL", group = grpExtra)
dxyRvolColor   = input.color(color.orange, "DXY RVOL color", group = grpExtra)
us10yRvolColor = input.color(color.lime, "US10Y RVOL color", group = grpExtra)
zbRvolColor    = input.color(color.purple, "ZB RVOL color", group = grpExtra)
dxySource   = input.source(volume, "DXY RVOL Source", group = grpExtra)
us10ySource = input.source(volume, "US10Y RVOL Source", group = grpExtra)
zbSource    = input.source(volume, "ZB RVOL Source", group = grpExtra)

// ---------- BREADTH SETTINGS ----------
grpBreadth = "Breadth Settings (TICK / ADD)"
tickSym    = input.symbol("TICK", "NYSE TICK", group = grpBreadth)
addSym     = input.symbol("ADD",  "NYSE Advance/Decline (ADD)", group = grpBreadth)
tickSource = input.source(close, "TICK Source", group = grpBreadth)
addSource  = input.source(close, "ADD Source",  group = grpBreadth)
breadthScale = input.int(500, "Scale divisor (for chart fit)", minval = 1, group = grpBreadth)
showTick   = input.bool(true, "Show TICK", group = grpBreadth)
showAdd    = input.bool(true, "Show ADD", group = grpBreadth)
tickColor  = input.color(color.yellow, "TICK color", group = grpBreadth)
addColor   = input.color(color.fuchsia, "ADD color", group = grpBreadth)

// ---------- SESSION / TIMEZONE SETTINGS ----------
grpSession = "Session Settings"
exchTZ     = input.string("America/New_York", "Exchange timezone", options = [
     "America/New_York", "America/Chicago", "America/Los_Angeles",
     "Europe/London", "Europe/Berlin", "Europe/Zurich",
     "Asia/Tokyo", "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Singapore",
     "Australia/Sydney", "UTC"], group = grpSession)
highlightPremarket = input.bool(false, "Highlight pre-market session (4:00–9:30 ET default)", group = grpSession)
premktStartHour = input.int(4, "Pre-market start hour", minval = 0, maxval = 23, group = grpSession)
premktStartMin  = input.int(0, "Pre-market start minute", minval = 0, maxval = 59, group = grpSession)
premktEndHour   = input.int(9, "Pre-market end hour", minval = 0, maxval = 23, group = grpSession)
premktEndMin    = input.int(30, "Pre-market end minute", minval = 0, maxval = 59, group = grpSession)
premktBgColor   = input.color(color.new(color.blue, 90), "Pre-market highlight color", group = grpSession)

// ---------- RVOL: cumulative volume vs N-day avg at same time-of-day ----------
minuteOfDay = hour(time, exchTZ) * 60 + minute(time, exchTZ)

var float cumVolToday = 0.0
newDay = ta.change(time("D")) != 0
cumVolToday := newDay ? rvolSource : cumVolToday + rvolSource

var matrix<float> volMatrix = matrix.new<float>(lookbackDays, 1440, na)
var int dayPtr = 0
if newDay
    dayPtr := (dayPtr + 1) % lookbackDays

matrix.set(volMatrix, dayPtr, minuteOfDay, cumVolToday)

f_avgAtMinute(m) =>
    total = 0.0
    cnt = 0
    for d = 0 to lookbackDays - 1
        v = matrix.get(volMatrix, d, m)
        if not na(v) and v > 0
            total += v
            cnt += 1
    cnt > 0 ? total / cnt : na

avgCumVol = f_avgAtMinute(minuteOfDay)
rvol = na(avgCumVol) or avgCumVol == 0 ? na : cumVolToday / avgCumVol

// ---------- RVOL for additional instruments (DXY, US10Y, ZB) ----------
f_symbolRvol(sym, src) =>
    v = request.security(sym, "1", src, lookahead = barmerge.lookahead_off)
    var float cumVol = 0.0
    cumVol := newDay ? v : cumVol + v
    var matrix<float> m = matrix.new<float>(lookbackDays, 1440, na)
    var int ptr = 0
    if newDay
        ptr := (ptr + 1) % lookbackDays
    matrix.set(m, ptr, minuteOfDay, cumVol)
    total = 0.0
    cnt = 0
    for d = 0 to lookbackDays - 1
        val = matrix.get(m, d, minuteOfDay)
        if not na(val) and val > 0
            total += val
            cnt += 1
    avg = cnt > 0 ? total / cnt : na
    na(avg) or avg == 0 ? na : cumVol / avg

dxyRvol   = f_symbolRvol(dxySym, dxySource)
us10yRvol = f_symbolRvol(us10ySym, us10ySource)
zbRvol    = f_symbolRvol(zbSym, zbSource)

// ---------- NYSE TICK / ADD breadth ----------
tickVal = request.security(tickSym, "1", tickSource, lookahead = barmerge.lookahead_off)
addVal  = request.security(addSym,  "1", addSource,  lookahead = barmerge.lookahead_off)

// ---------- Pre-market session highlight ----------
premktStartMins = premktStartHour * 60 + premktStartMin
premktEndMins   = premktEndHour * 60 + premktEndMin
inPremarket     = minuteOfDay >= premktStartMins and minuteOfDay < premktEndMins
bgcolor(highlightPremarket and inPremarket ? premktBgColor : na)

// ---------- Plots ----------
plot(rvol, "RVOL", color = rvolColor, linewidth = rvolWidth)
hline(1.0, "Avg Volume (1.0x)", color = color.gray, linestyle = hline.style_dashed, display = showRvolLines ? display.all : display.none)
hline(rvolElevated, "Elevated", color = color.orange, linestyle = hline.style_dotted, display = showRvolLines ? display.all : display.none)
hline(rvolHeavy, "Heavy", color = color.red, linestyle = hline.style_dotted, display = showRvolLines ? display.all : display.none)

plot(showTick ? tickVal / breadthScale : na, "NYSE TICK (scaled)", color = tickColor)
plot(showAdd ? addVal / breadthScale : na,  "NYSE ADD (scaled)",  color = addColor)
hline(0, "Zero", color = color.gray)

plot(showDxyRvol ? dxyRvol : na, "DXY RVOL", color = dxyRvolColor)
plot(showUs10yRvol ? us10yRvol : na, "US10Y RVOL", color = us10yRvolColor)
plot(showZbRvol ? zbRvol : na, "ZB RVOL", color = zbRvolColor)
````
