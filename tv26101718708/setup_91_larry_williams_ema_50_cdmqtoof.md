# Setup 9.1 (Larry Williams) + EMA 50

- url: https://www.tradingview.com/script/cdmqtoOf/
- type: indicator
- pine_id: PUB;49bedcc765a249e691408ad970de44b1
- version: 1.0

## Description

Disclaimer
This indicator is strictly a visual charting tool for educational purposes. It does NOT provide financial advice or buy/sell recommendations. Trading involves risk; perform your own analysis.

Overview and Logic
This script automates the visual layout of Larry Williams 9.1 Setup combined with a 50 MA trend filter. It highlights short-term momentum shifts based on moving average directional changes:

BUY Setup: Triggered when the 9 EMA turns UP. The script plots a visual entry line at the signal bar High and an invalidation line at its Low.

SELL Setup: Triggered when the 9 EMA turns DOWN. The script plots a visual entry line at the signal bar Low and an invalidation line at its High.

The 50 MA acts as an optional macro filter line to help you identify the broader market direction.

Alerts Notice
Alerts trigger at the close of the signal bar when the visual setup forms. An alert does NOT mean a trade is executed. The setup is only validated if the price breaks the plotted trigger line on the subsequent bars.

## Source Code

````pine
//@version=6
indicator("Setup 9.1 (Larry Williams) + EMA 50", overlay=true)

// ══════════════════════════════════════════════════════════════════
//  INPUT SETTINGS
// ══════════════════════════════════════════════════════════════════
// --- MA 1 (Main 9.1 Signal) ---
group1    = "Moving Average 1 (9.1 Signal)"
typeMa1   = input.string("EMA",        "MA 1 Type",          options=["EMA", "SMA"], group=group1)
len       = input.int(9,               "MA 1 Length",        minval=1, group=group1)

// --- MA 2 (Filter/Auxiliary) ---
group2    = "Moving Average 2 (Filter)"
showMa2   = input.bool(true,           "Show MA 2",          group=group2)
typeMa2   = input.string("EMA",        "MA 2 Type",          options=["EMA", "SMA"], group=group2)
len2      = input.int(50,              "MA 2 Length",        minval=1, group=group2)

// ══════════════════════════════════════════════════════════════════
//  MOVING AVERAGES LOGIC
// ══════════════════════════════════════════════════════════════════
get_ma(type, src, length) =>
    type == "EMA" ? ta.ema(src, length) : ta.sma(src, length)

ma1 = get_ma(typeMa1, close, len)
ma2 = get_ma(typeMa2, close, len2)

ma1up   = ma1 > ma1[1]
ma1down = ma1 < ma1[1]

maColor = ma1up ? color.new(#1cff78, 0) : ma1down ? color.new(#FF0000, 0) : color.new(#ffeb3b, 0)

plot(ma1, title="Moving Average 1 (9.1)", linewidth=2, color=maColor)
plot(showMa2 ? ma2 : na, title="Moving Average 2", linewidth=2, color=color.new(#9C27B0, 0))

// ══════════════════════════════════════════════════════════════════
//  SIGNALS & CALCULATIONS (HIGH / LOW MODE ACTIVE)
// ══════════════════════════════════════════════════════════════════
buySignal  = ma1up   and not ma1up[1]
sellSignal = ma1down and not ma1down[1]

var float buyTrigger  = na
var float buyStop     = na
var float sellTrigger = na
var float sellStop    = na

if buySignal
    buyTrigger := high
    buyStop    := low
else if not ma1up
    buyTrigger := na
    buyStop    := na

if sellSignal
    sellTrigger := low
    sellStop    := high
else if not ma1down
    sellTrigger := na
    sellStop    := na

// ══════════════════════════════════════════════════════════════════
//  VISUAL PLOTS (SHAPES & LINES)
// ══════════════════════════════════════════════════════════════════
barcolor(buySignal  and close > open ? color.new(#1cff78, 0) : na, title="Buy Bar Color")
barcolor(sellSignal and close < open ? color.new(#FF0000, 0) : na, title="Sell Bar Color")

plotshape(buySignal,  title="9.1 BUY Shape",  style=shape.arrowup,   location=location.belowbar, color=color.new(#1cff78, 0), size=size.small, text="BUY 9.1",  textcolor=color.new(#1cff78, 0))
plotshape(sellSignal, title="9.1 SELL Shape", style=shape.arrowdown, location=location.abovebar, color=color.new(#FF0000, 0), size=size.small, text="SELL 9.1", textcolor=color.new(#FF0000, 0))

plot(not na(buyTrigger)  ? buyTrigger  : na, "Buy Entry Level", color=color.new(#1cff78, 0),  style=plot.style_linebr, linewidth=1)
plot(not na(buyStop)     ? buyStop     : na, "Buy Stop Level",   color=color.new(#1cff78, 60), style=plot.style_linebr, linewidth=1)
plot(not na(sellTrigger) ? sellTrigger : na, "Sell Entry Level", color=color.new(#FF0000, 0),  style=plot.style_linebr, linewidth=1)
plot(not na(sellStop)    ? sellStop    : na, "Sell Stop Level",  color=color.new(#FF0000, 60), style=plot.style_linebr, linewidth=1)

// Alerts
alertcondition(buySignal,  title="9.1 Buy Alert",  message="9.1 Setup - BUY Signal")
alertcondition(sellSignal, title="9.1 Sell Alert", message="9.1 Setup - SELL Signal")
````
