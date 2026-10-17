#  ES/NQ Judas Swing 

- url: https://www.tradingview.com/script/OE3ExJ10-ES-NQ-Judas-Swing/
- type: indicator
- pine_id: PUB;360947cd4f0348cf95cf3cbbaf1ad6ca
- version: 1.0

## Description

Judas Swing
Implement the Judas Swing model: 9:30–11:00 ET liquidity sweep followed by MSB toward opposite liquidity, with FVG entry zones.
On session open, maps the pre-session high/low as liquidity targets. Watches for a sweep of one side, then waits for market structure break in the opposite direction. Optionally marks FVGs in-session for entry precision.

How to use:

Best on ES/NQ 1m–5m
Session window default: 14:00–16:00 UTC (NY 9–11 EDT)
LIQ tags = sweep candidates; MSB labels = structure break entries
Opposite-side liquidity = TP

Settings: sessionStart / sessionEnd in HHMM UTC.

Alerts: Bear sweep, Bull sweep, Judas Short, Judas Long.

## Source Code

````pine
//@version=5
indicator(" Judas Swing ", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// Built from sunny's notes:
//   - Trade window: 9:30 AM - 11:00 AM ET (2:30 PM - 4:00 PM UTC for ES)
//   - Map structural liquidity on 5m before window opens
//   - Wait for price to sweep one side first
//   - On 1m: look for MSB (Market Structure Break) toward opposite liquidity
//   - Entry: at FVG inside the displacement, OR at MSB break+retest
//   - SL: below local MS shift, TP: opposite liquidity (4:1 R:R common)
//   - Liq grab invalidated if price continues in same direction after sweep

// Inputs
sessionStart = input.int(1400, "Session start (HHMM UTC)", tooltip="14:00 UTC = 9 AM ET, 1430 = 9:30 AM ET")
sessionEnd   = input.int(1600, "Session end (HHMM UTC)")
liqPivLen    = input.int(10,  "Liquidity pivot lookback (5m equivalent)")
showFVG      = input.bool(true,"Highlight FVGs in session")
showSwept    = input.bool(true,"Highlight liquidity sweeps")
fvgMinSize   = input.float(0.0, "Min FVG size (price points)", step=0.1)
colHi        = input.color(color.new(color.red,   70), "High liq")
colLo        = input.color(color.new(color.green, 70), "Low liq")
colFVGup     = input.color(color.new(color.lime,  85), "FVG up")
colFVGdn     = input.color(color.new(color.red,   85), "FVG down")
colSweep     = input.color(color.orange, "Sweep")
colMSB       = input.color(color.fuchsia,"MSB")

// Session window
hUTC = hour(time, "UTC")
mUTC = minute(time, "UTC")
nowHM = hUTC * 100 + mUTC
inSession = nowHM >= sessionStart and nowHM < sessionEnd
sessionOpen = inSession and not inSession[1]

// Liquidity levels: highest high and lowest low of last N bars before session
ph = ta.pivothigh(high, liqPivLen, liqPivLen)
pl = ta.pivotlow (low,  liqPivLen, liqPivLen)
var float liqHi = na
var float liqLo = na
var int   liqHiBar = na
var int   liqLoBar = na

if not na(ph)
    liqHi    := ph
    liqHiBar := bar_index - liqPivLen
if not na(pl)
    liqLo    := pl
    liqLoBar := bar_index - liqPivLen

// Draw liquidity lines on session open
var line lineHi = na
var line lineLo = na
if sessionOpen
    if not na(lineHi)
        line.delete(lineHi)
    if not na(lineLo)
        line.delete(lineLo)
    if not na(liqHi)
        lineHi := line.new(liqHiBar, liqHi, bar_index + 100, liqHi, color=colHi, width=1, style=line.style_dashed)
    if not na(liqLo)
        lineLo := line.new(liqLoBar, liqLo, bar_index + 100, liqLo, color=colLo, width=1, style=line.style_dashed)

// Sweep detection (in-session only)
var bool sweptHi = false
var bool sweptLo = false
var int sweptHiBar = na
var int sweptLoBar = na

if sessionOpen
    sweptHi := false
    sweptLo := false
    sweptHiBar := na
    sweptLoBar := na

bearSweep = inSession and not sweptHi and not na(liqHi) and high > liqHi and close < liqHi
bullSweep = inSession and not sweptLo and not na(liqLo) and low  < liqLo and close > liqLo

if bearSweep
    sweptHi := true
    sweptHiBar := bar_index
if bullSweep
    sweptLo := true
    sweptLoBar := bar_index

plotshape(bearSweep and showSwept, "Bear sweep", shape.triangledown, location.abovebar, color=colSweep, size=size.normal, text="LIQ")
plotshape(bullSweep and showSwept, "Bull sweep", shape.triangleup,   location.belowbar, color=colSweep, size=size.normal, text="LIQ")

// FVG detection (3-bar): bullish FVG when low[0] > high[2]; bearish when high[0] < low[2]
fvgUp  = inSession and low > high[2] and (low - high[2]) >= fvgMinSize
fvgDn  = inSession and high < low[2] and (low[2] - high) >= fvgMinSize

if showFVG and fvgUp
    box.new(bar_index - 2, low, bar_index, high[2], border_color=color.new(color.lime, 50), bgcolor=colFVGup)
if showFVG and fvgDn
    box.new(bar_index - 2, low[2], bar_index, high, border_color=color.new(color.red, 50), bgcolor=colFVGdn)

// MSB after sweep: short side - after bearSweep, lower-low takeout
// long side - after bullSweep, higher-high takeout
var float postSweepLow  = na
var float postSweepHigh = na

if bearSweep
    postSweepLow := low
if bullSweep
    postSweepHigh := high

if not na(postSweepLow) and inSession
    postSweepLow := math.min(postSweepLow, low)
if not na(postSweepHigh) and inSession
    postSweepHigh := math.max(postSweepHigh, high)

msbShort = inSession and sweptHi and not na(postSweepLow) and close < postSweepLow and close < open
msbLong  = inSession and sweptLo and not na(postSweepHigh) and close > postSweepHigh and close > open

plotshape(msbShort, "MSB short", shape.labeldown, location.abovebar, color=colMSB, size=size.normal, text="MSB", textcolor=color.white)
plotshape(msbLong,  "MSB long",  shape.labelup,   location.belowbar, color=colMSB, size=size.normal, text="MSB", textcolor=color.white)

// Entry/SL/TP draw on MSB
if msbShort
    e = close
    sl = math.max(high, high[1])
    tp = liqLo
    line.new(bar_index, e,  bar_index + 30, e,  color=color.red,   width=2)
    line.new(bar_index, sl, bar_index + 30, sl, color=color.red,   style=line.style_dashed)
    if not na(tp)
        line.new(bar_index, tp, bar_index + 30, tp, color=color.green, style=line.style_dashed)
        label.new(bar_index + 30, tp, "TP " + str.tostring(tp, format.mintick), style=label.style_label_left, color=color.new(color.green, 40), textcolor=color.white, size=size.tiny)

if msbLong
    e = close
    sl = math.min(low, low[1])
    tp = liqHi
    line.new(bar_index, e,  bar_index + 30, e,  color=color.green, width=2)
    line.new(bar_index, sl, bar_index + 30, sl, color=color.red,   style=line.style_dashed)
    if not na(tp)
        line.new(bar_index, tp, bar_index + 30, tp, color=color.green, style=line.style_dashed)
        label.new(bar_index + 30, tp, "TP " + str.tostring(tp, format.mintick), style=label.style_label_left, color=color.new(color.green, 40), textcolor=color.white, size=size.tiny)

bgcolor(inSession ? color.new(color.aqua, 95) : na, title="Session shade")

alertcondition(bearSweep, "Bear sweep", "Liquidity swept high")
alertcondition(bullSweep, "Bull sweep", "Liquidity swept low")
alertcondition(msbShort,  "Judas Short", "ICT Judas Swing short setup")
alertcondition(msbLong,   "Judas Long",  "ICT Judas Swing long setup")
````
