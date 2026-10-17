# Custom Anchored Daily VWAP + Bands

- url: https://www.tradingview.com/script/OGItXW36-Custom-Anchored-Daily-VWAP-Bands/
- type: indicator
- pine_id: PUB;043821aad60d4dfeba5e82093ac36b75
- version: 1.0

## Description

24H vwap  with bands, you choose at what hour (and minute) the anchor starts. Bands are not connected to anchor points, so you see previous vwap band levels. Vibe-coded via Claude.

## Source Code

````pine
//@version=6
indicator("Custom Anchored Daily VWAP + Bands", "C-VWAP", overlay=true)

// ─── Inputs ───
startHour = input.int(9,  "Reset Hour (0-23)",   minval=0, maxval=23, group="Session Start")
startMin  = input.int(30, "Reset Minute (0-59)", minval=0, maxval=59, group="Session Start")
tzOpt     = input.string("Exchange", "Timezone",
     options=["Exchange", "UTC", "Europe/Amsterdam", "America/New_York", "Europe/London"],
     group="Session Start")
src       = input.source(hlc3, "Source", group="Calculation")

show1 = input.bool(true,  "Band 1", inline="b1", group="Bands")
mult1 = input.float(1.0,  "×",      inline="b1", group="Bands", minval=0, step=0.1)
show2 = input.bool(true,  "Band 2", inline="b2", group="Bands")
mult2 = input.float(2.0,  "×",      inline="b2", group="Bands", minval=0, step=0.1)

// Resolve timezone string
tz = tzOpt == "Exchange" ? syminfo.timezone : tzOpt

// ─── Detect the daily reset ───
anchor = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), startHour, startMin, 0)
newSession = time >= anchor and time[1] < anchor

// ─── VWAP + variance accumulation ───
var float sumPV  = 0.0
var float sumPV2 = 0.0
var float sumV   = 0.0

if newSession
    sumPV  := 0.0
    sumPV2 := 0.0
    sumV   := 0.0

sumPV  += src * volume
sumPV2 += src * src * volume
sumV   += volume

vwap = sumV != 0 ? sumPV / sumV : na
variance = sumV != 0 ? math.max(sumPV2 / sumV - vwap * vwap, 0.0) : na
dev = math.sqrt(variance)

up1 = vwap + mult1 * dev
dn1 = vwap - mult1 * dev
up2 = vwap + mult2 * dev
dn2 = vwap - mult2 * dev

// ─── Alternate each session between two plot layers (A / B) ───
var int sid = 0
if newSession
    sid += 1
isA = sid % 2 == 0

cV = color.new(color.blue, 0)
cT = color.new(color.teal, 0)
cM = color.new(color.maroon, 0)

// VWAP
plot(isA ? vwap : na, "VWAP A", color=cV, linewidth=2, style=plot.style_linebr)
plot(isA ? na : vwap, "VWAP B", color=cV, linewidth=2, style=plot.style_linebr)

// Band 1 (teal)
u1a = plot(isA     and show1 ? up1 : na, "U1 A", color=cT, style=plot.style_linebr)
d1a = plot(isA     and show1 ? dn1 : na, "D1 A", color=cT, style=plot.style_linebr)
u1b = plot(not isA and show1 ? up1 : na, "U1 B", color=cT, style=plot.style_linebr)
d1b = plot(not isA and show1 ? dn1 : na, "D1 B", color=cT, style=plot.style_linebr)
fill(u1a, d1a, color=show1 ? color.new(color.teal, 92) : na)
fill(u1b, d1b, color=show1 ? color.new(color.teal, 92) : na)

// Band 2 (maroon)
u2a = plot(isA     and show2 ? up2 : na, "U2 A", color=cM, style=plot.style_linebr)
d2a = plot(isA     and show2 ? dn2 : na, "D2 A", color=cM, style=plot.style_linebr)
u2b = plot(not isA and show2 ? up2 : na, "U2 B", color=cM, style=plot.style_linebr)
d2b = plot(not isA and show2 ? dn2 : na, "D2 B", color=cM, style=plot.style_linebr)
fill(u2a, d2a, color=show2 ? color.new(color.maroon, 95) : na)
fill(u2b, d2b, color=show2 ? color.new(color.maroon, 95) : na)

bgcolor(newSession ? color.new(color.gray, 85) : na, title="Reset marker")
````
