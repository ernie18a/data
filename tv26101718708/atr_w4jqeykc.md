# ATR 

- url: https://www.tradingview.com/script/w4JqeYKC-ATR/
- type: indicator
- pine_id: PUB;beb11d81035e474985a9f172e8604695
- version: 1.0

## Description

EV ATR Signals  transforms a basic ATR level indicator into a fully functional trend-following system built on Supertrend logic.

Instead of recalculating fixed levels on every bar, the trailing stop only moves in the direction of the trend — never against it. This means signals are generated only when price genuinely breaks the structure, filtering out the noise that plagues standard ATR buy/sell indicators.

What it does:

Supertrend trailing stop — green below price (bull trend), red above price (bear trend)
BUY / SELL labels appear only at real trend flips, not on every bar
TP1 & TP2 levels projected from the entry price using ATR multiples (fully adjustable)
Price-to-stop fill — shaded zone shows how much buffer you have before the trend changes
Bar coloring by trend direction
2 alert conditions — BUY Signal, SELL Signal
Settings:

ATR Length & Multiplier — controls sensitivity (default 14 / 2.0)
TP1 / TP2 Multiplier — target distance in ATR units from entry
Toggle fills, bar colors, and labels independently

## Source Code

````pine

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © EV Quant Lab

//@version=6
indicator("EV ATR Signals PRO", shorttitle="EV ATR", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
atrLen    = input.int(14,   "ATR Length",      minval=1,             group="ATR")
mult      = input.float(2.0,"ATR Multiplier",  minval=0.1, step=0.1, group="ATR")

showTP    = input.bool(true,  "Show TP1 / TP2 Levels", group="Targets")
tpMult1   = input.float(1.0, "TP1 Multiplier (× ATR)", minval=0.1, step=0.1, group="Targets")
tpMult2   = input.float(2.0, "TP2 Multiplier (× ATR)", minval=0.1, step=0.1, group="Targets")

colorBars = input.bool(true,  "Color Bars by Trend",   group="Visual")
showFill  = input.bool(true,  "Fill Band to Price",     group="Visual")
showSigs  = input.bool(true,  "Show Signal Labels",     group="Visual")

// ─────────────────────────────────────────────
// SUPERTREND CORE
// ─────────────────────────────────────────────
atr = ta.atr(atrLen)
upperBand = hl2 + mult * atr
lowerBand = hl2 - mult * atr

var float trailUp   = na
var float trailDown = na
var int   trend     = 1

prevUp   = nz(trailUp[1],   upperBand)
prevDown = nz(trailDown[1], lowerBand)

trailDown := lowerBand > prevDown or close[1] < prevDown ? lowerBand : prevDown
trailUp   := upperBand < prevUp   or close[1] > prevUp   ? upperBand : prevUp

trend := close > trailUp[1] ? 1 : close < trailDown[1] ? -1 : nz(trend[1], 1)

trendLine = trend == 1 ? trailDown : trailUp

bull = trend ==  1
bear = trend == -1

// ─────────────────────────────────────────────
// SIGNALS
// ─────────────────────────────────────────────
buySignal  = trend ==  1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] ==  1

// ─────────────────────────────────────────────
// TP LEVELS
// ─────────────────────────────────────────────
var float tp1Bull = na
var float tp2Bull = na
var float tp1Bear = na
var float tp2Bear = na

if buySignal
    tp1Bull := close + atr * tpMult1
    tp2Bull := close + atr * tpMult2
    tp1Bear := na
    tp2Bear := na

if sellSignal
    tp1Bear := close - atr * tpMult1
    tp2Bear := close - atr * tpMult2
    tp1Bull := na
    tp2Bull := na

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
lineColor = bull ? color.new(#00c853, 0) : color.new(#f44336, 0)

plot(trendLine, "Trend Stop", color=lineColor, linewidth=2, style=plot.style_linebr)

plot(showTP ? tp1Bull : na, "TP1 Bull", color=color.new(#00c853, 50), linewidth=1, style=plot.style_linebr)
plot(showTP ? tp2Bull : na, "TP2 Bull", color=color.new(#00c853, 20), linewidth=2, style=plot.style_linebr)
plot(showTP ? tp1Bear : na, "TP1 Bear", color=color.new(#f44336, 50), linewidth=1, style=plot.style_linebr)
plot(showTP ? tp2Bear : na, "TP2 Bear", color=color.new(#f44336, 20), linewidth=2, style=plot.style_linebr)

closePlot = plot(close,     display=display.none)
stopPlot  = plot(trendLine, display=display.none)
fill(closePlot, stopPlot, color=showFill ? (bull ? color.new(#00c853, 92) : color.new(#f44336, 92)) : na)

barcolor(colorBars ? (bull ? color.new(#00c853, 40) : color.new(#f44336, 40)) : na)

if showSigs and buySignal
    label.new(bar_index, low, "▲ BUY\n" + str.tostring(close, format.mintick),
         style=label.style_label_up, color=color.new(#00c853, 0), textcolor=color.white, size=size.small)

if showSigs and sellSignal
    label.new(bar_index, high, "▼ SELL\n" + str.tostring(close, format.mintick),
         style=label.style_label_down, color=color.new(#f44336, 0), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(buySignal,  title="BUY Signal",  message="EV ATR BUY signal on {{ticker}} {{interval}} — Price: {{close}}")
alertcondition(sellSignal, title="SELL Signal", message="EV ATR SELL signal on {{ticker}} {{interval}} — Price: {{close}}")
````
