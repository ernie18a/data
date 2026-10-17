# Peachy ORB Opening Range Breakout

- url: https://www.tradingview.com/script/GC2l3CVo-Peachy-ORB-Opening-Range-Breakout/
- type: indicator
- pine_id: PUB;4a1a602b96f04b29a277185af9f3dba2
- version: 1.0

## Description

Peachy ORB — Opening Range Breakout Scalper

A precision opening range tool for 15-minute stock scalping, built around the first 15 and 30 minutes of the regular session with pre-market context layered in.

What it does

Peachy ORB tracks three critical price ranges and surfaces high-probability reversal entries when price interacts with them:

15-min ORB (9:30–9:45 ET) — purple dashed lines marking the first 3 candles' high/low
30-min ORB (9:30–10:00 ET) — blue filled box with a 50% mid-level for mean-reversion plays
Pre-market ORB (4:00–9:29 ET) — orange box showing overnight sentiment and likely magnets

Instead of chasing breakouts, Peachy ORB looks for failed breakouts and rejections — the setups that consistently pay on opening range trades.

Signals

Four signal types plot directly on your chart:

Bullish Reject (↑) — Price dipped below the 30-min low, then closed back above it. Failed breakdown = long setup

Bearish Reject (↓) — Price pushed above the 30-min high, then closed back below. Failed breakout = short setup

Higher Low (circle) — Three consecutive higher lows forming above the ORB low, confirming long bias

Lower High (circle) — Three consecutive lower highs below the ORB high, confirming short bias

Range day warning

If price is still trapped inside the 30-min range at 10:15 ET, the background turns yellow — your signal to stand down. Range days chop up scalpers. The indicator tells you when to sit on your hands.

Why it works

The first 30 minutes of the session set the tone for most stock moves. Price that gets rejected at the opening range edges almost always retests the other side. Peachy ORB doesn't try to predict direction — it waits for the tape to show its hand, then flags the reversal as it's confirming.

Best for

5-minute charts on liquid US equities (SPY, QQQ, high-volume single names)
9:45 ET onward — the 15-min box is locked and meaningful
Pair with level 2 or volume confirmation for scalps

Alerts

Five built-in alerts cover bullish/bearish rejections, higher-low/lower-high confirmations, and the range day warning.

Not financial advice. Backtest on your preferred tickers before going live.

A few notes on the script itself before you publish — worth sanity checking:

The 15-min ORB "window" logic has a redundant condition: (hour == 9 and minute >= 30 and minute < 45) or (hour == 9 and minute == 30) — the second clause is already covered by the first

Your chart timezone needs to be set to New York for the hour/minute checks to work correctly; worth mentioning in the description or handling with timestamp() in a session input
Consider using input.session() for the ORB windows so international users can adapt it without editing the code

Yours Truly,
Mr. Bags

## Source Code

````pine
//@version=6
indicator("Peachy ORB — Opening Range Breakout", overlay=true, max_lines_count=20, max_boxes_count=10, max_labels_count=20)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
show15       = input.bool(true,  "Show 15-min ORB (purple lines)",   group="ORB Levels")
show30       = input.bool(true,  "Show 30-min ORB Box",              group="ORB Levels")
showPreMkt   = input.bool(true,  "Show Pre-Market ORB Box",          group="ORB Levels")
show50       = input.bool(true,  "Show 50% Mid-Level",               group="ORB Levels")
showLabels   = input.bool(true,  "Show Level Labels",                group="ORB Levels")
extendLines  = input.bool(true,  "Extend lines to right",            group="ORB Levels")

color15      = input.color(color.new(#9C27B0, 0),   "15-min ORB color",     group="Colors")
color30      = input.color(color.new(#2196F3, 20),  "30-min ORB box color", group="Colors")
colorPre     = input.color(color.new(#FF9800, 20),  "Pre-mkt ORB color",    group="Colors")
color50      = input.color(color.new(#00BCD4, 0),   "50% line color",       group="Colors")
colorBull    = input.color(color.new(#10b981, 0),   "Bullish signal",       group="Colors")
colorBear    = input.color(color.new(#ef4444, 0),   "Bearish signal",       group="Colors")

alertsOn     = input.bool(true, "Enable alerts",                    group="Alerts")

// ─────────────────────────────────────────────
// SESSION LOGIC
// ─────────────────────────────────────────────
// Market open: 09:30 ET  |  Pre-market start: 04:00 ET
isRegularOpen = (hour == 9  and minute == 30)
isPreMktStart = (hour == 4  and minute == 0)
isNewDay      = ta.change(dayofweek) != 0 or (hour == 0 and minute == 0)

// We track session bars since open
var int barsSinceOpen = 0
if isRegularOpen
    barsSinceOpen := 0
else
    barsSinceOpen += 1

// ─────────────────────────────────────────────
// 15-MIN ORB  (first 3 × 5-min candles = bars 0–2 on a 5-min chart)
// On other timeframes, we use time-based detection.
// ─────────────────────────────────────────────
var float orb15High = na
var float orb15Low  = na
var bool  orb15Done = false

// Reset at market open
if isRegularOpen
    orb15High := high
    orb15Low  := low
    orb15Done := false

// Build the 15-min range until 09:45
inOrb15Window = (hour == 9 and minute >= 30 and minute < 45) or (hour == 9 and minute == 30)
if inOrb15Window and not isRegularOpen
    orb15High := math.max(orb15High, high)
    orb15Low  := math.min(orb15Low,  low)

// Lock it at 09:45
if hour == 9 and minute == 45 and not orb15Done
    orb15Done := true

// ─────────────────────────────────────────────
// 30-MIN ORB  (first 6 × 5-min candles, or first 30 min)
// ─────────────────────────────────────────────
var float orb30High = na
var float orb30Low  = na
var bool  orb30Done = false

if isRegularOpen
    orb30High := high
    orb30Low  := low
    orb30Done := false

inOrb30Window = (hour == 9 and minute >= 30) or (hour == 10 and minute == 0)
if inOrb30Window and not orb30Done and not isRegularOpen
    orb30High := math.max(orb30High, high)
    orb30Low  := math.min(orb30Low,  low)

if hour == 10 and minute == 0 and not orb30Done
    orb30Done := true

orb30Mid = (orb30High + orb30Low) / 2

// ─────────────────────────────────────────────
// PRE-MARKET ORB  (04:00–09:29)
// ─────────────────────────────────────────────
var float preMktHigh = na
var float preMktLow  = na
var bool  preMktDone = false

if isPreMktStart
    preMktHigh := high
    preMktLow  := low
    preMktDone := false

inPreMktWindow = hour >= 4 and (hour < 9 or (hour == 9 and minute < 30))
if inPreMktWindow and not isPreMktStart and not preMktDone
    preMktHigh := math.max(preMktHigh, high)
    preMktLow  := math.min(preMktLow,  low)

if isRegularOpen
    preMktDone := true

// ─────────────────────────────────────────────
// DRAW LEVELS  (updated on each bar once locked)
// ─────────────────────────────────────────────
lineRight = extendLines ? extend.right : extend.none

// 15-min ORB — horizontal lines (purple)
var line line15H = na
var line line15L = na

if orb15Done and show15
    if na(line15H)
        line15H := line.new(bar_index, orb15High, bar_index + 1, orb15High, color=color15, width=2, style=line.style_dashed, extend=lineRight)
        line15L := line.new(bar_index, orb15Low,  bar_index + 1, orb15Low,  color=color15, width=2, style=line.style_dashed, extend=lineRight)
    else
        line.set_y1(line15H, orb15High)
        line.set_y2(line15H, orb15High)
        line.set_y1(line15L, orb15Low)
        line.set_y2(line15L, orb15Low)

// 30-min ORB — filled box (blue)
var box  box30  = na
var line line50 = na

if orb30Done and show30
    if na(box30)
        box30  := box.new(bar_index, orb30High, bar_index + 1, orb30Low, bgcolor=color.new(color30, 85), border_color=color.new(color30, 30), border_width=2)
    else
        box.set_top(box30, orb30High)
        box.set_bottom(box30, orb30Low)
    if show50
        if na(line50)
            line50 := line.new(bar_index, orb30Mid, bar_index + 1, orb30Mid, color=color50, width=1, style=line.style_dotted, extend=lineRight)
        else
            line.set_y1(line50, orb30Mid)
            line.set_y2(line50, orb30Mid)

// Pre-market ORB — filled box (orange)
var box boxPre = na

if preMktDone and showPreMkt
    if na(boxPre)
        boxPre := box.new(bar_index, preMktHigh, bar_index + 1, preMktLow, bgcolor=color.new(colorPre, 88), border_color=color.new(colorPre, 20), border_width=1, border_style=line.style_dashed)
    else
        box.set_top(boxPre, preMktHigh)
        box.set_bottom(boxPre, preMktLow)

// ─────────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────────
if orb30Done and show30 and showLabels and barstate.islast
    label.new(bar_index + 2, orb30High, "ORB 30H", style=label.style_label_left, color=color.new(color30, 60), textcolor=color.white, size=size.small)
    label.new(bar_index + 2, orb30Low,  "ORB 30L", style=label.style_label_left, color=color.new(color30, 60), textcolor=color.white, size=size.small)
    label.new(bar_index + 2, orb30Mid,  "50%",     style=label.style_label_left, color=color.new(color50,  60), textcolor=color.white, size=size.small)

if orb15Done and show15 and showLabels and barstate.islast
    label.new(bar_index + 2, orb15High, "ORB 15H", style=label.style_label_left, color=color.new(color15, 50), textcolor=color.white, size=size.small)
    label.new(bar_index + 2, orb15Low,  "ORB 15L", style=label.style_label_left, color=color.new(color15, 50), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────
// SIGNAL DETECTION — Peachy Method
// (Reject below/above ORB, wait for confirmation)
// ─────────────────────────────────────────────
afterOrb30   = orb30Done and hour >= 10

// Bullish: price dipped below ORB 30 low, then candle closed back above it (failed breakdown → long)
bullishReject = afterOrb30 and close[1] < orb30Low and close > orb30Low and close > open

// Bearish: price pushed above ORB 30 high, then candle closed back below it (failed breakout → short)
bearishReject = afterOrb30 and close[1] > orb30High and close < orb30High and close < open

// Higher low forming above ORB low (long confirmation)
higherLow = afterOrb30 and low > low[1] and low[1] > low[2] and close > orb30Low

// Lower high forming below ORB high (short confirmation)
lowerHigh = afterOrb30 and high < high[1] and high[1] < high[2] and close < orb30High

// ─────────────────────────────────────────────
// PLOT SIGNALS
// ─────────────────────────────────────────────
plotshape(bullishReject, title="Bullish Reject",  location=location.belowbar, style=shape.triangleup,   color=colorBull, size=size.small, text="↑ Reject")
plotshape(bearishReject, title="Bearish Reject",  location=location.abovebar, style=shape.triangledown, color=colorBear, size=size.small, text="↓ Reject")
plotshape(higherLow,     title="Higher Low (Long conf)", location=location.belowbar, style=shape.circle, color=color.new(colorBull, 40), size=size.tiny)
plotshape(lowerHigh,     title="Lower High (Short conf)", location=location.abovebar, style=shape.circle, color=color.new(colorBear, 40), size=size.tiny)

// ─────────────────────────────────────────────
// BACKGROUND — range day warning (still inside ORB at 10:15)
// ─────────────────────────────────────────────
rangeDay = orb30Done and hour == 10 and minute >= 15 and close > orb30Low and close < orb30High
bgcolor(rangeDay ? color.new(color.yellow, 93) : na, title="Range Day Warning")

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
if alertsOn
    if bullishReject
        alert("ORB: Bullish rejection off 30-min low — watch for long setup", alert.freq_once_per_bar)
    if bearishReject
        alert("ORB: Bearish rejection off 30-min high — watch for short setup", alert.freq_once_per_bar)
    if higherLow
        alert("ORB: Higher low confirmed above ORB — potential long entry", alert.freq_once_per_bar)
    if lowerHigh
        alert("ORB: Lower high confirmed below ORB — potential short entry", alert.freq_once_per_bar)
    if rangeDay
        alert("ORB: Still inside range at 10:15 — range-based day likely", alert.freq_once_per_bar)
````
