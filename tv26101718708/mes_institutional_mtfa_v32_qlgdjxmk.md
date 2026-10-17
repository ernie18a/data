# MES Institutional MTFA v3.2

- url: https://www.tradingview.com/script/QLGDJXmK-MES-Institutional-MTFA-v3-2/
- type: indicator
- pine_id: PUB;97e8ac24264642a38e1aeff9b448ed18
- version: 1.0

## Description

Institutional-grade multi-timeframe analysis tool for MES (Micro E-mini S&P 500) futures. Combines Elliott Wave structure, Fibonacci confluences, MACD divergence, and a proprietary 3-7-11 swing counter algorithm to identify high-probability reversal zones and mean-reversion setups.

## Source Code

````pine
//@version=6
// ============================================================================
// MES INSTITUTIONAL MTFA v3.2 — FINAL FIX
// ============================================================================
indicator("MES Institutional MTFA v3.2", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ───────────────────────── INPUTS ─────────────────────────
grp1 = "CORE SETTINGS"
show_daily = input.bool(true, "Show Daily Levels", group=grp1)
show_4h = input.bool(true, "Show 4H Levels", group=grp1)
show_fibs = input.bool(true, "Show Fibonacci Zones", group=grp1)
show_swings = input.bool(true, "Show 3-7-11 Swing Counter", group=grp1)
show_signals = input.bool(true, "Show Entry Signals", group=grp1)

grp2 = "EMA SETTINGS"
ema21_len = input.int(21, "21 EMA Length (5M Trigger)", group=grp2, minval=1)
ema50_len = input.int(50, "50 EMA Length (Confluence)", group=grp2, minval=1)
daily_ema = input.int(50, "Daily 50 EMA Length", group=grp2, minval=1)

grp3 = "SWING ALGORITHM (3-7-11)"
swing_len = input.int(5, "Pivot Lookback", group=grp3, minval=2, maxval=50)

grp4 = "FIBONACCI LEVELS"
show_382 = input.bool(true, "0.382 Level", group=grp4)
show_500 = input.bool(true, "0.500 Level", group=grp4)
show_618 = input.bool(true, "0.618 Level (Golden Pocket)", group=grp4)
show_786 = input.bool(true, "0.786 Level", group=grp4)

// ───────────────────────── EMA PLOTS ─────────────────────────
ema21 = ta.ema(close, ema21_len)
ema50 = ta.ema(close, ema50_len)

daily_50ema = request.security(syminfo.tickerid, "D", ta.ema(close, daily_ema), lookahead=barmerge.lookahead_off)

plot(ema21, "21 EMA", color=color.new(color.red, 20), linewidth=2)
plot(ema50, "50 EMA", color=color.new(color.blue, 20), linewidth=2)
plot(daily_50ema, "Daily 50 EMA", color=color.new(color.orange, 30), linewidth=3, style=plot.style_cross)

// ───────────────────────── PIVOT DETECTION ─────────────────────────
pivotHigh = ta.pivothigh(high, swing_len, swing_len)
pivotLow = ta.pivotlow(low, swing_len, swing_len)

var float swingHigh = 0.0
var float swingLow = 0.0
var int swingCounter = 0
var int lastSwingDir = 0
var bool hasFirstHigh = false
var bool hasFirstLow = false

if not na(pivotHigh)
    swingHigh := high[swing_len]
    swingCounter += 1
    lastSwingDir := 1
    hasFirstHigh := true
    if show_swings
        label.new(bar_index[swing_len], swingHigh, "S" + str.tostring(swingCounter), style=label.style_label_down, color=color.new(color.red, 60), textcolor=color.white, size=size.small)

if not na(pivotLow)
    swingLow := low[swing_len]
    swingCounter += 1
    lastSwingDir := -1
    hasFirstLow := true
    if show_swings
        label.new(bar_index[swing_len], swingLow, "S" + str.tostring(swingCounter), style=label.style_label_up, color=color.new(color.green, 60), textcolor=color.white, size=size.small)

isTerminal = swingCounter == 3 or swingCounter == 7 or swingCounter == 11
isIncomplete = swingCounter == 5

plotshape(isIncomplete and show_swings, "5-Swing Incomplete", shape.triangledown, location.abovebar, color=color.new(color.yellow, 0), size=size.small, text="5", textcolor=color.yellow)

// ───────────────────────── FIBONACCI ZONES ─────────────────────────
var float fibHigh = 0.0
var float fibLow = 0.0

if not na(pivotHigh)
    fibHigh := high[swing_len]
if not na(pivotLow)
    fibLow := low[swing_len]

fibRange = fibHigh - fibLow
fib_382 = fibHigh - (fibRange * 0.382)
fib_500 = fibHigh - (fibRange * 0.500)
fib_618 = fibHigh - (fibRange * 0.618)
fib_786 = fibHigh - (fibRange * 0.786)

fibReady = hasFirstHigh and hasFirstLow and (fibHigh > fibLow)

if show_fibs and fibReady
    var box fibBox = na
    box.delete(fibBox)
    fibBox := box.new(bar_index - 50, fib_786, bar_index + 20, fib_382, bgcolor=color.new(color.purple, 90), border_color=color.new(color.purple, 60))

plot(show_382 and fibReady ? fib_382 : na, "Fib 0.382", color=color.new(color.aqua, 50), linewidth=1, style=plot.style_stepline)
plot(show_500 and fibReady ? fib_500 : na, "Fib 0.500", color=color.new(color.yellow, 50), linewidth=1, style=plot.style_stepline)
plot(show_618 and fibReady ? fib_618 : na, "Fib 0.618", color=color.new(color.orange, 30), linewidth=2, style=plot.style_stepline)
plot(show_786 and fibReady ? fib_786 : na, "Fib 0.786", color=color.new(color.red, 50), linewidth=1, style=plot.style_stepline)

//
````
