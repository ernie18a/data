# XAU Clear EMA ATR Strategy TP SL Voice V6

- url: https://www.tradingview.com/script/zudiHFjK-XAU-Clear-EMA-ATR-Strategy-TP-SL-Voice-V6/
- type: strategy
- pine_id: PUB;712471d8c1404512b25bd609fe9303f1
- version: 1.0

## Description

XAU Clear EMA ATR Strategy TP SL Voice is a strategy designed for XAU/USD. It uses two EMA moving averages to identify market direction and ATR volatility to calculate clear Stop Loss and Take Profit levels.

BUY signals appear when price confirms a move back above the fast EMA while the fast EMA is above the slow EMA, showing bullish market conditions.

SELL signals appear when price confirms a move back below the fast EMA while the fast EMA is below the slow EMA, showing bearish market conditions.

The Stop Loss is calculated using ATR, making it adaptive to current volatility. The strategy includes five Take Profit levels:

TP1 STRONG and TP2 STRONG: higher-probability targets.
TP3 GOOD: trend continuation target.
TP4 and TP5 AGGRESSIVE: extended targets for stronger market moves.

The chart clearly displays:
BUY ENTRY / SELL ENTRY
STOP LOSS
TP1, TP2, TP3, TP4 and TP5

The script also includes TradingView-ready voice alert messages for BUY and SELL signals.

Example Screenshots:

Example 1: BUY Setup
The chart shows a confirmed BUY ENTRY after price moves above the fast EMA in a bullish trend. The blue line marks the entry, the red line marks Stop Loss, and the green/yellow/orange lines show TP1 to TP5.

Example 2: SELL Setup
The chart shows a confirmed SELL ENTRY after price moves below the fast EMA in a bearish trend. The Stop Loss is placed above entry using ATR, while TP levels are projected below the entry.

Example 3: TP Levels
TP1 and TP2 are marked as STRONG targets, TP3 as a GOOD continuation target, and TP4/TP5 as AGGRESSIVE targets for stronger trend movement.

Recommended markets:
XAU/USD

Recommended timeframes:
5M, 15M, 30M

## Source Code

````pine
//@version=6
strategy("XAU Clear EMA ATR Strategy TP SL Voice V6", overlay=true, max_labels_count=100, process_orders_on_close=true)

fastLen = input.int(21, "EMA Fast")
slowLen = input.int(50, "EMA Slow")
atrLen = input.int(14, "ATR Length")
slAtr = input.float(1.5, "SL ATR Multiplier")

tp1R = input.float(0.7, "TP1 STRONG")
tp2R = input.float(1.2, "TP2 STRONG")
tp3R = input.float(1.8, "TP3 GOOD")
tp4R = input.float(2.5, "TP4 AGGRESSIVE")
tp5R = input.float(3.5, "TP5 AGGRESSIVE")

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atrValue = ta.atr(atrLen)

buySignal = barstate.isconfirmed and emaFast > emaSlow and close > emaFast and close[1] <= emaFast[1]
sellSignal = barstate.isconfirmed and emaFast < emaSlow and close < emaFast and close[1] >= emaFast[1]

var float entry = na
var float sl = na
var float tp1 = na
var float tp2 = na
var float tp3 = na
var float tp4 = na
var float tp5 = na
var int dir = 0

var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var label tp4Label = na
var label tp5Label = na

clearLabels() =>
    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
    label.delete(tp4Label)
    label.delete(tp5Label)

roundPrice(x) =>
    math.round(x / syminfo.mintick) * syminfo.mintick

if buySignal
    clearLabels()

    entry := roundPrice(close)
    sl := roundPrice(entry - atrValue * slAtr)
    risk = entry - sl

    tp1 := roundPrice(entry + risk * tp1R)
    tp2 := roundPrice(entry + risk * tp2R)
    tp3 := roundPrice(entry + risk * tp3R)
    tp4 := roundPrice(entry + risk * tp4R)
    tp5 := roundPrice(entry + risk * tp5R)
    dir := 1

    strategy.close("SELL")
    strategy.entry("BUY", strategy.long)

    entryLabel := label.new(bar_index, entry, "BUY ENTRY\n" + str.tostring(entry, format.mintick), style=label.style_label_up, color=color.blue, textcolor=color.white)
    slLabel := label.new(bar_index, sl, "STOP LOSS\n" + str.tostring(sl, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)
    tp1Label := label.new(bar_index, tp1, "TP1 STRONG\n" + str.tostring(tp1, format.mintick), style=label.style_label_left, color=color.lime, textcolor=color.black)
    tp2Label := label.new(bar_index, tp2, "TP2 STRONG\n" + str.tostring(tp2, format.mintick), style=label.style_label_left, color=color.lime, textcolor=color.black)
    tp3Label := label.new(bar_index, tp3, "TP3 GOOD\n" + str.tostring(tp3, format.mintick), style=label.style_label_left, color=color.yellow, textcolor=color.black)
    tp4Label := label.new(bar_index, tp4, "TP4 AGGR\n" + str.tostring(tp4, format.mintick), style=label.style_label_left, color=color.orange, textcolor=color.white)
    tp5Label := label.new(bar_index, tp5, "TP5 AGGR\n" + str.tostring(tp5, format.mintick), style=label.style_label_left, color=color.orange, textcolor=color.white)

    alert("MALE VOICE BUY XAUUSD. Entry " + str.tostring(entry, format.mintick) + ". Stop loss " + str.tostring(sl, format.mintick), alert.freq_once_per_bar_close)

if sellSignal
    clearLabels()

    entry := roundPrice(close)
    sl := roundPrice(entry + atrValue * slAtr)
    risk = sl - entry

    tp1 := roundPrice(entry - risk * tp1R)
    tp2 := roundPrice(entry - risk * tp2R)
    tp3 := roundPrice(entry - risk * tp3R)
    tp4 := roundPrice(entry - risk * tp4R)
    tp5 := roundPrice(entry - risk * tp5R)
    dir := -1

    strategy.close("BUY")
    strategy.entry("SELL", strategy.short)

    entryLabel := label.new(bar_index, entry, "SELL ENTRY\n" + str.tostring(entry, format.mintick), style=label.style_label_down, color=color.blue, textcolor=color.white)
    slLabel := label.new(bar_index, sl, "STOP LOSS\n" + str.tostring(sl, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)
    tp1Label := label.new(bar_index, tp1, "TP1 STRONG\n" + str.tostring(tp1, format.mintick), style=label.style_label_left, color=color.lime, textcolor=color.black)
    tp2Label := label.new(bar_index, tp2, "TP2 STRONG\n" + str.tostring(tp2, format.mintick), style=label.style_label_left, color=color.lime, textcolor=color.black)
    tp3Label := label.new(bar_index, tp3, "TP3 GOOD\n" + str.tostring(tp3, format.mintick), style=label.style_label_left, color=color.yellow, textcolor=color.black)
    tp4Label := label.new(bar_index, tp4, "TP4 AGGR\n" + str.tostring(tp4, format.mintick), style=label.style_label_left, color=color.orange, textcolor=color.white)
    tp5Label := label.new(bar_index, tp5, "TP5 AGGR\n" + str.tostring(tp5, format.mintick), style=label.style_label_left, color=color.orange, textcolor=color.white)

    alert("MALE VOICE SELL XAUUSD. Entry " + str.tostring(entry, format.mintick) + ". Stop loss " + str.tostring(sl, format.mintick), alert.freq_once_per_bar_close)

if dir == 1
    strategy.exit("BUY TP1", "BUY", limit=tp1, stop=sl, qty_percent=20)
    strategy.exit("BUY TP2", "BUY", limit=tp2, stop=sl, qty_percent=20)
    strategy.exit("BUY TP3", "BUY", limit=tp3, stop=sl, qty_percent=20)
    strategy.exit("BUY TP4", "BUY", limit=tp4, stop=sl, qty_percent=20)
    strategy.exit("BUY TP5", "BUY", limit=tp5, stop=sl, qty_percent=20)

if dir == -1
    strategy.exit("SELL TP1", "SELL", limit=tp1, stop=sl, qty_percent=20)
    strategy.exit("SELL TP2", "SELL", limit=tp2, stop=sl, qty_percent=20)
    strategy.exit("SELL TP3", "SELL", limit=tp3, stop=sl, qty_percent=20)
    strategy.exit("SELL TP4", "SELL", limit=tp4, stop=sl, qty_percent=20)
    strategy.exit("SELL TP5", "SELL", limit=tp5, stop=sl, qty_percent=20)

plot(emaFast, "EMA Fast", color=color.aqua, linewidth=2)
plot(emaSlow, "EMA Slow", color=color.orange, linewidth=2)

plot(dir != 0 ? entry : na, "ENTRY", color=color.blue, linewidth=3, style=plot.style_linebr)
plot(dir != 0 ? sl : na, "STOP LOSS", color=color.red, linewidth=3, style=plot.style_linebr)
plot(dir != 0 ? tp1 : na, "TP1 STRONG", color=color.lime, linewidth=3, style=plot.style_linebr)
plot(dir != 0 ? tp2 : na, "TP2 STRONG", color=color.lime, linewidth=3, style=plot.style_linebr)
plot(dir != 0 ? tp3 : na, "TP3 GOOD", color=color.yellow, linewidth=2, style=plot.style_linebr)
plot(dir != 0 ? tp4 : na, "TP4 AGGRESSIVE", color=color.orange, linewidth=2, style=plot.style_linebr)
plot(dir != 0 ? tp5 : na, "TP5 AGGRESSIVE", color=color.orange, linewidth=1, style=plot.style_linebr)

plotshape(buySignal, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white)
plotshape(sellSignal, title="SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white)

alertcondition(buySignal, title="VOICE BUY", message="MALE VOICE BUY XAUUSD")
alertcondition(sellSignal, title="VOICE SELL", message="MALE VOICE SELL XAUUSD")
````
