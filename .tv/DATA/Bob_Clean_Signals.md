<!-- tradingview-pine-id: PUB;8f48ec406eb540eebeefa29efe3f38eb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bob Clean Signals

Source: https://www.tradingview.com/script/UVHUdFl6-Bob-Clean-Signals/

## Description

Bob Clean Signals marks pullback entries into market structure and into two
user-defined session ranges.

HOW IT WORKS
1. Structure zone: the script tracks the most recent confirmed pivot high and
   pivot low (ta.pivothigh / ta.pivotlow, symmetrical length). When price closes
   beyond one of them, that break defines a zone spanning the two pivots, and
   the trend is set bullish or bearish. The zone is discarded when price closes
   through the opposite side, or after N bars.
2. Session zones: at two configurable New York times (default 09:00 and 15:00),
   the high and low of that bar become a range. The range only arms once price
   has closed outside it.
3. Entry: price must retrace back into a zone between the Min and Max Pullback
   levels (measured as a fraction of the zone's height), and the bar must close
   as a rejection candle in the trend direction. A cooldown enforces a minimum
   bar spacing between signals.

SETTINGS
Pivot Length — lookback each side for pivot confirmation.
Min / Max Pullback % — the retracement band that counts as a valid entry.
Invalidate Zone After N Bars — age limit on a structure zone.
First Touch Only — allow one signal per structure zone.
Zone 1 / Zone 2 Hour and Minute — session times in New York time.
Only Session Signals — suppress structure-based signals.
Min Bars Between Signals — cooldown.

NOTES
Session zones require an intraday chart. Pivots confirm Pivot Length bars after
they form, so a zone appears only after that confirmation; signals are evaluated
on the live bar and are final at bar close.

This is an indicator, not a strategy, and it does not backtest or measure
performance. It is for study and chart annotation only and is not financial
advice.

---

## Source Code

````pine
//@version=6
indicator("Bob Clean Signals", shorttitle="BOB Clean Signals", overlay=true, max_boxes_count=120, max_labels_count=100)

// ─── Inputs ───────────────────────────────────────────────
grpS = "Structure"
pivotLen       = input.int(3, "Pivot Length", minval=2, maxval=7, group=grpS)
minPullback    = input.float(0.25, "Min Pullback %", minval=0.0, maxval=1.0, step=0.05, group=grpS)
maxPullback    = input.float(0.75, "Max Pullback %", minval=0.0, maxval=1.0, step=0.05, group=grpS)
zoneMaxAge     = input.int(80, "Invalidate Zone After N Bars", minval=20, group=grpS)
firstTouchOnly = input.bool(false, "Structure Zone: First Touch Only", group=grpS)

grpT = "Session Zones (New York time)"
showTimeZones = input.bool(true, "Show Session Zones", group=grpT)
s1Hour = input.int(9,  "Zone 1 Hour",   minval=0, maxval=23, group=grpT, inline="z1")
s1Min  = input.int(0,  ":",             minval=0, maxval=59, group=grpT, inline="z1")
s2Hour = input.int(15, "Zone 2 Hour",   minval=0, maxval=23, group=grpT, inline="z2")
s2Min  = input.int(0,  ":",             minval=0, maxval=59, group=grpT, inline="z2")

grpD = "Display"
showZones     = input.bool(true, "Show Structure Zones", group=grpD)
showSignals   = input.bool(true, "Show Signals", group=grpD)
onlyTimeBased = input.bool(false, "Only Session-Zone Signals", group=grpD)
cooldownBars  = input.int(6, "Min Bars Between Signals", minval=3, group=grpD)
useLabels     = input.bool(false, "Use Text Labels Instead of Arrows", group=grpD)
offsetATR     = input.float(0.12, "Label Offset (x ATR)", minval=0.0, step=0.05, group=grpD)

if barstate.isfirst and minPullback >= maxPullback
    runtime.error("Min Pullback % must be smaller than Max Pullback %")

atr = ta.atr(14)

// ─── Time (New York) ──────────────────────────────────────
// Session zones only make sense on intraday charts.
intraday  = timeframe.isintraday
nyHour    = hour(time, "America/New_York")
nyMin     = minute(time, "America/New_York")
minOfDay  = nyHour * 60 + nyMin
newNYDay  = ta.change(dayofmonth(time, "America/New_York")) != 0

// Fire once per calendar day on the first bar at or after the target time,
// so the zones stay correct on any intraday resolution and on 24h sessions.
var bool s1Done = false
var bool s2Done = false
if newNYDay
    s1Done := false
    s2Done := false

isZone1 = intraday and not s1Done and minOfDay >= s1Hour * 60 + s1Min
isZone2 = intraday and not s2Done and minOfDay >= s2Hour * 60 + s2Min
if isZone1
    s1Done := true
if isZone2
    s2Done := true

// ─── Pivots ───────────────────────────────────────────────
// Confirmed pivotLen bars after the fact — values never change once printed.
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPH = na
var float lastPL = na
var int   lastPHbar = na
var int   lastPLbar = na

if not na(ph)
    lastPH    := ph
    lastPHbar := bar_index - pivotLen
if not na(pl)
    lastPL    := pl
    lastPLbar := bar_index - pivotLen

// ─── Structure Zone ───────────────────────────────────────
var string trend   = "neutral"
var float  zHigh   = na
var float  zLow    = na
var bool   zActive = false
var int    zBar    = na
var box    zBox    = na
var bool   firstTouchUsed = false

haveP   = not na(lastPH) and not na(lastPL)
bullBOS = haveP and close > lastPH and close[1] <= lastPH
bearBOS = haveP and close < lastPL and close[1] >= lastPL

if bullBOS or bearBOS
    zHigh   := lastPH
    zLow    := lastPL
    zActive := true
    zBar    := bar_index
    trend   := bullBOS ? "bullish" : "bearish"
    firstTouchUsed := false
    if showZones
        if not na(zBox)
            box.delete(zBox)
        zLeft = math.min(nz(lastPHbar, bar_index), nz(lastPLbar, bar_index))
        zCol  = bullBOS ? color.green : color.red
        zBox := box.new(zLeft, zHigh, bar_index + 8, zLow,
                        bgcolor=color.new(zCol, 90),
                        border_color=color.new(zCol, 50),
                        border_width=1)

// Invalidate zone
if zActive
    broken = (trend == "bullish" and close < zLow) or (trend == "bearish" and close > zHigh)
    if broken or (bar_index - zBar > zoneMaxAge)
        zActive := false
        trend   := "neutral"
        firstTouchUsed := false

if zActive and showZones and not na(zBox)
    box.set_right(zBox, bar_index + 6)

// ─── Session Zones ────────────────────────────────────────
var float s1High = na
var float s1Low  = na
var bool  s1Active = false
var box   s1Box = na

var float s2High = na
var float s2Low  = na
var bool  s2Active = false
var box   s2Box = na

if newNYDay
    s1High := na
    s1Low  := na
    s1Active := false
    s2High := na
    s2Low  := na
    s2Active := false

if isZone1
    s1High := high
    s1Low  := low
    s1Active := false
    if showTimeZones
        if not na(s1Box)
            box.delete(s1Box)
        s1Box := box.new(bar_index, s1High, bar_index + 25, s1Low,
                         bgcolor=color.new(color.blue, 88), border_color=color.blue, border_width=2)

if isZone2
    s2High := high
    s2Low  := low
    s2Active := false
    if showTimeZones
        if not na(s2Box)
            box.delete(s2Box)
        s2Box := box.new(bar_index, s2High, bar_index + 25, s2Low,
                         bgcolor=color.new(color.purple, 88), border_color=color.purple, border_width=2)

// A session zone only arms once price has left its range.
if not na(s1High) and not s1Active and (close > s1High or close < s1Low)
    s1Active := true
if not na(s2High) and not s2Active and (close > s2High or close < s2Low)
    s2Active := true

if showTimeZones and s1Active and not na(s1Box)
    box.set_right(s1Box, bar_index + 8)
if showTimeZones and s2Active and not na(s2Box)
    box.set_right(s2Box, bar_index + 8)

// ─── Pullback Detection ───────────────────────────────────
inBull(hi, lo, active) =>
    sz = hi - lo
    active and not na(sz) and sz > 0 and low <= hi - sz * minPullback and low >= hi - sz * maxPullback

inBear(hi, lo, active) =>
    sz = hi - lo
    active and not na(sz) and sz > 0 and high >= lo + sz * minPullback and high <= lo + sz * maxPullback

zArmed   = zActive and not (firstTouchOnly and firstTouchUsed)
inZBull  = inBull(zHigh, zLow, zArmed and trend == "bullish")
inZBear  = inBear(zHigh, zLow, zArmed and trend == "bearish")
inS1Bull = inBull(s1High, s1Low, s1Active)
inS1Bear = inBear(s1High, s1Low, s1Active)
inS2Bull = inBull(s2High, s2Low, s2Active)
inS2Bear = inBear(s2High, s2Low, s2Active)

// Rejection candle confirming the pullback
bullRej = close > open and (close > high[1] or close > close[1])
bearRej = close < open and (close < low[1]  or close < close[1])

// ─── Signals ──────────────────────────────────────────────
var int lastSignalBar = na

buySetup  = onlyTimeBased ? (inS1Bull or inS2Bull) and bullRej : (inZBull or inS1Bull or inS2Bull) and bullRej
sellSetup = onlyTimeBased ? (inS1Bear or inS2Bear) and bearRej : (inZBear or inS1Bear or inS2Bear) and bearRej

canSignal  = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars
buySignal  = showSignals and buySetup  and canSignal
sellSignal = showSignals and sellSetup and canSignal and not buySignal

if buySignal or sellSignal
    lastSignalBar := bar_index
    if inZBull or inZBear
        firstTouchUsed := true

// ─── Plotting ─────────────────────────────────────────────
plotshape(not useLabels and buySignal,  title="BUY",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 0), size=size.tiny)
plotshape(not useLabels and sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0),  size=size.tiny)

if useLabels and buySignal
    label.new(bar_index, low - atr * offsetATR, "BUY",
              style=label.style_label_up, color=color.new(color.lime, 0),
              textcolor=color.black, size=size.small, yloc=yloc.price)

if useLabels and sellSignal
    label.new(bar_index, high + atr * offsetATR, "SELL",
              style=label.style_label_down, color=color.new(color.red, 0),
              textcolor=color.white, size=size.small, yloc=yloc.price)

alertcondition(buySignal,  "BOB Buy",  "BOB BUY signal")
alertcondition(sellSignal, "BOB Sell", "BOB SELL signal")

zoneBg = zActive and trend == "bullish" ? color.new(color.green, 96) : zActive and trend == "bearish" ? color.new(color.red, 96) : color(na)
bgcolor(zoneBg, title="Trend Background")
````
