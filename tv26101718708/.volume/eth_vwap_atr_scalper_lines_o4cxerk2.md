# ETH VWAP ATR Scalper Lines

- url: https://www.tradingview.com/script/O4cXErK2-ETH-VWAP-ATR-Scalper-Lines/
- type: indicator
- pine_id: PUB;821d777f2a81428fa0eb77fd280490dd
- version: 1.0

## Description

this is the full ETH VWAP ATR Scalper Lines script, and it includes:

VWAP line.

Entry line.

Stop line.

TP1 line.

TP2 line.

BUY/SELL triangle signals.

Alert conditions.

Info label with ATR, VWAP, entry, stop, and targets.

Small note
This version does not include the stats table or box-style labels. It is the simpler line-and-triangle version you had before. If you want the one you liked best, that was the version with:

box-style BUY/SELL labels,

stats table,

and the same entry/stop/TP lines

## Source Code

````pine
//@version=5
indicator("ETH VWAP ATR Scalper Lines", overlay=true)

lenAtr = input.int(14, "ATR Length")
lookback = input.int(5, "Swing Lookback")
useRsi = input.bool(true, "Use RSI Filter")
rsiLen = input.int(14, "RSI Length")
showLabels = input.bool(true, "Show Labels")

vwapVal = ta.vwap(hlc3)
atrVal = ta.atr(lenAtr)
buffer = atrVal * 0.15
swingHigh = ta.highest(high, lookback)
swingLow = ta.lowest(low, lookback)
rsiVal = ta.rsi(close, rsiLen)

longTrig = barstate.isconfirmed and close > vwapVal + buffer and close > open and close > high[1] and (not useRsi or rsiVal > 50)
shortTrig = barstate.isconfirmed and close < vwapVal - buffer and close < open and close < low[1] and (not useRsi or rsiVal < 50)

var float entryLine = na
var float stopLine = na
var float tp1Line = na
var float tp2Line = na

if longTrig
    entryLine := close
    stopLine := swingLow - buffer
    tp1Line := close + atrVal
    tp2Line := close + atrVal * 2
    if showLabels
        label.new(bar_index, low - buffer, "BUY", style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.small)

if shortTrig
    entryLine := close
    stopLine := swingHigh + buffer
    tp1Line := close - atrVal
    tp2Line := close - atrVal * 2
    if showLabels
        label.new(bar_index, high + buffer, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

plot(vwapVal, "VWAP", color=color.orange, linewidth=2)
plot(entryLine, "Entry", color=color.blue, linewidth=2, style=plot.style_linebr)
plot(stopLine, "Stop", color=color.red, linewidth=2, style=plot.style_linebr)
plot(tp1Line, "TP1", color=color.green, linewidth=2, style=plot.style_linebr)
plot(tp2Line, "TP2", color=color.teal, linewidth=2, style=plot.style_linebr)

alertcondition(longTrig, title="Long Signal", message="ETH VWAP ATR Scalper Lines: BUY")
alertcondition(shortTrig, title="Short Signal", message="ETH VWAP ATR Scalper Lines: SELL")

var label info = na
if barstate.islast
    label.delete(info)
    txt = "ATR: " + str.tostring(atrVal, format.mintick) + "\n" +
          "VWAP: " + str.tostring(vwapVal, format.mintick) + "\n" +
          "Entry: " + str.tostring(entryLine, format.mintick) + "\n" +
          "Stop: " + str.tostring(stopLine, format.mintick) + "\n" +
          "TP1: " + str.tostring(tp1Line, format.mintick) + "\n" +
          "TP2: " + str.tostring(tp2Line, format.mintick)
    info := label.new(bar_index, high, txt, style=label.style_label_left, textcolor=color.white, color=color.new(color.blue, 60))
````
