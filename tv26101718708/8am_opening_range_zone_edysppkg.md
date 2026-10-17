# 8AM Opening Range Zone

- url: https://www.tradingview.com/script/edySPpKg-8AM-Opening-Range-Zone/
- type: indicator
- pine_id: PUB;9cbd126d11204b1faf56a1a1761e8de2
- version: 1.0

## Description

RP Profits inspired ORB Break and Retest. In development. (Use at own risk)

## Source Code

````pine
//@version=6
indicator("8AM Opening Range Zone", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ── Inputs ──────────────────────────────────────────────────────────────
tz        = input.string("America/New_York", "Timezone")
orHour    = input.int(8,  "Open hour (24h)",    minval = 0, maxval = 23, group = "Session")
orMin     = input.int(0,  "Open minute",        minval = 0, maxval = 59, group = "Session")
orLenMin  = input.int(15, "Opening range (min)", minval = 1,             group = "Session")
endHour   = input.int(18, "Close hour (24h)",   minval = 0, maxval = 23, group = "Session")
endMin    = input.int(0,  "Close minute",       minval = 0, maxval = 59, group = "Session")

invalPts  = input.float(20, "Invalidate at ≥ (pts)", minval = 0, group = "Invalidation")
markInval = input.bool(true,  "Tint invalidated zone red", group = "Invalidation")

enSignals = input.bool(true, "Enable long/short signals", group = "Signals")
entHour   = input.int(9,  "Earliest entry hour (24h)", minval = 0, maxval = 23, group = "Signals")
entMin    = input.int(30, "Earliest entry minute",     minval = 0, maxval = 59, group = "Signals")
blockInv  = input.bool(true, "No signals if zone invalidated", group = "Signals")

slPct  = input.float(25,  "Stop beyond zone (% of height)", minval = 0, group = "Risk/Reward")
rMult  = input.float(2.5, "Target (R multiple)",            minval = 0, group = "Risk/Reward")
rrBars = input.int(50,    "RR box width (bars)",            minval = 1, group = "Risk/Reward")
slFill = input.color(color.new(color.red, 80),   "Stop zone",     group = "Risk/Reward")
slBord = input.color(color.new(color.red, 40),   "Stop border",   group = "Risk/Reward")
tpFill = input.color(color.new(color.green, 80), "Target zone",   group = "Risk/Reward")
tpBord = input.color(color.new(color.green, 40), "Target border", group = "Risk/Reward")

zoneCol   = input.color(color.new(color.blue, 85), "Zone fill",   group = "Style")
borderCol = input.color(color.new(color.blue, 30), "Zone border", group = "Style")
invalFill = input.color(color.new(color.red, 85),  "Invalid fill",   group = "Style")
invalBord = input.color(color.new(color.red, 30),  "Invalid border", group = "Style")
showLabel = input.bool(true, "Show height label", group = "Style")
showMid   = input.bool(true, "Show midline",      group = "Style")
midCol    = input.color(color.new(color.gray, 0), "Midline",        group = "Style")

// ── Day-anchored timestamps (DST-aware via tz) ──────────────────────────
y  = year(time, tz)
mo = month(time, tz)
d  = dayofmonth(time, tz)

orStart    = timestamp(tz, y, mo, d, orHour, orMin, 0)
orEnd      = orStart + orLenMin * 60 * 1000
entryStart = timestamp(tz, y, mo, d, entHour, entMin, 0)
sessEnd    = timestamp(tz, y, mo, d, endHour, endMin, 0)

// ── Draw a risk/reward bracket (red stop box, green target box) ─────────
drawRR(bool isLong, float entry, float sl, float tp) =>
    box.new(bar_index, isLong ? entry : sl, bar_index + rrBars, isLong ? sl : entry, xloc = xloc.bar_index, bgcolor = slFill, border_color = slBord, border_width = 1, text = "SL  " + str.tostring(sl, format.mintick), text_color = color.new(color.red, 0), text_size = size.small, text_halign = text.align_left, text_valign = isLong ? text.align_bottom : text.align_top)
    box.new(bar_index, isLong ? tp : entry, bar_index + rrBars, isLong ? entry : tp, xloc = xloc.bar_index, bgcolor = tpFill, border_color = tpBord, border_width = 1, text = "TP  " + str.tostring(tp, format.mintick) + "  (" + str.tostring(rMult, "#.#") + "R)", text_color = color.new(color.green, 0), text_size = size.small, text_halign = text.align_left, text_valign = isLong ? text.align_top : text.align_bottom)
    line.new(bar_index, entry, bar_index + rrBars, entry, xloc = xloc.bar_index, color = color.new(color.gray, 0), width = 1)
    label.new(bar_index + rrBars, entry, "Entry " + str.tostring(entry, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_right, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)

// ── State ───────────────────────────────────────────────────────────────
var box   zoneBox  = na
var line  midLine  = na
var label hgtLabel = na
var float orHigh   = na
var float orLow    = na
var bool  zoneInval= false
var float maxAbove = 0.0   // furthest price ran above the zone this session
var float maxBelow = 0.0   // furthest price ran below the zone this session
var bool  brokeUp  = false // price has CLOSED above the zone this session
var bool  brokeDn  = false // price has CLOSED below the zone this session
var bool  longArm  = false // broke up, now retesting back inside  → await bullish candle
var bool  shortArm = false // broke down, now retesting back inside → await bearish candle
var bool  fired    = false // one entry per day

isOR      = time >= orStart and time < orEnd       // bar inside 8:00–8:15
isFirstOR = isOR and not isOR[1]                   // first bar of today's range

if isFirstOR
    orHigh    := high
    orLow     := low
    zoneInval := false
    maxAbove  := 0.0
    maxBelow  := 0.0
    brokeUp   := false
    brokeDn   := false
    longArm   := false
    shortArm  := false
    fired     := false
    zoneBox := box.new(orStart, orHigh, sessEnd, orLow, xloc = xloc.bar_time, bgcolor = zoneCol, border_color = borderCol, border_width = 1)
    if showMid
        mid = (orHigh + orLow) / 2
        midLine := line.new(orStart, mid, sessEnd, mid, xloc = xloc.bar_time, color = midCol, style = line.style_dotted)
    if showLabel
        hgtLabel := label.new(orStart, orHigh, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_down, color = color.new(color.black, 100), size = size.small)
else if isOR
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow,  low)
    box.set_top(zoneBox, orHigh)
    box.set_bottom(zoneBox, orLow)
    if showMid
        mid = (orHigh + orLow) / 2
        line.set_y1(midLine, mid)
        line.set_y2(midLine, mid)

// ── Height + invalidation (every bar of the range) ──────────────────────
if isOR
    height      = orHigh - orLow
    zoneInval  := markInval and invalPts > 0 and height >= invalPts
    box.set_bgcolor(zoneBox, zoneInval ? invalFill : zoneCol)
    box.set_border_color(zoneBox, zoneInval ? invalBord : borderCol)
    if showLabel
        label.set_xy(hgtLabel, orStart, orHigh)
        label.set_text(hgtLabel, str.tostring(height, "#.##") + " pts" + (zoneInval ? "  ✕ INVALID" : ""))
        label.set_textcolor(hgtLabel, zoneInval ? color.red : chart.fg_color)

// ── Track break (wick excursion for direction, close for the retest) ─────
afterOR = time >= orEnd and time < sessEnd and not na(orHigh)
if afterOR
    if high > orHigh
        maxAbove := math.max(maxAbove, high - orHigh)   // furthest up — sets dominant side
    if low < orLow
        maxBelow := math.max(maxBelow, orLow - low)     // furthest down — sets dominant side

    if close > orHigh                 // closed above → real up break, leave the zone
        brokeUp := true
        longArm := false
    else if close < orLow             // closed below → real down break, leave the zone
        brokeDn := true
        shortArm := false
    else                              // closed inside → retest; arm any side that broke
        if brokeUp
            longArm := true
        if brokeDn
            shortArm := true

// ── Signal: continuation candle that closes inside the zone, after 9:30 ──
// Arm on break+retest, then the first matching-direction candle that closes
// inside fires: bullish candle for a long, bearish for a short. Dominant side
// (bigger excursion) breaks ties when both sides broke.
bullCandle = close > open
bearCandle = close < open
entryOK = enSignals and afterOR and time >= entryStart and not (blockInv and zoneInval) and not fired

longSignal  = entryOK and longArm  and bullCandle and maxAbove > maxBelow
shortSignal = entryOK and shortArm and bearCandle and maxBelow > maxAbove

if longSignal or shortSignal
    fired := true

// ── Place the RR bracket on the signal bar ──────────────────────────────
height2 = orHigh - orLow
slDist  = slPct / 100 * height2          // breathing room past the signal candle
if longSignal
    entry = close
    sl    = low - slDist                 // below the indication candle's low
    drawRR(true, entry, sl, entry + rMult * (entry - sl))
if shortSignal
    entry = close
    sl    = high + slDist                // above the indication candle's high
    drawRR(false, entry, sl, entry - rMult * (sl - entry))

alertcondition(longSignal,  "OR Long Signal",  "8AM OR: long — bullish continuation candle inside zone after upside break")
alertcondition(shortSignal, "OR Short Signal", "8AM OR: short — bearish continuation candle inside zone after downside break")
````
