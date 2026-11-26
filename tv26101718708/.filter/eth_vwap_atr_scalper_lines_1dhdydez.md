# ETH VWAP ATR Scalper Lines

- url: https://www.tradingview.com/script/1dHdydEZ-ETH-VWAP-ATR-Scalper-Lines/
- type: indicator
- pine_id: PUB;c9b7727b557b4034af76702e8120f8f9
- version: 1.0

## Description

ETH VWAP ATR Scalper Lines
Treat the plotted levels as a scalping map, not as perfect predictions. The best results will still come when the signal lines up with VWAP bias, candle confirmation, and the broader micro-trend.

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

longTrig = close > vwapVal + buffer and close > open and close > high[1] and (not useRsi or rsiVal > 50)
shortTrig = close < vwapVal - buffer and close < open and close < low[1] and (not useRsi or rsiVal < 50)

var float entryLine = na
var float stopLine = na
var float tp1Line = na
var float tp2Line = na

if longTrig
    entryLine := close
    stopLine := swingLow - buffer
    tp1Line := close + atrVal
    tp2Line := close + atrVal * 2

if shortTrig
    entryLine := close
    stopLine := swingHigh + buffer
    tp1Line := close - atrVal
    tp2Line := close - atrVal * 2

plot(vwapVal, "VWAP", color=color.orange, linewidth=2)
plot(entryLine, "Entry", color=color.blue, linewidth=2, style=plot.style_linebr)
plot(stopLine, "Stop", color=color.red, linewidth=2, style=plot.style_linebr)
plot(tp1Line, "TP1", color=color.green, linewidth=2, style=plot.style_linebr)
plot(tp2Line, "TP2", color=color.teal, linewidth=2, style=plot.style_linebr)

plotshape(showLabels and longTrig, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY")
plotshape(showLabels and shortTrig, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

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
