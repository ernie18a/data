# ETH VWAP ATR Scalper Lines

- url: https://www.tradingview.com/script/MAF2qYyh-ETH-VWAP-ATR-Scalper-Lines/
- type: indicator
- pine_id: PUB;dc52502f759a4b9c85d9f9e9f84e2fd3
- version: 1.0

## Description

This script is a simple ETH scalping indicator.

It watches price relative to VWAP, uses ATR to create a buffer and target distances, and checks candle strength plus an optional RSI filter before printing a BUY or SELL signal. When a signal appears, it plots the entry, stop-loss, TP1, and TP2 levels on the chart, and the info box shows the current status as BUY, SELL, or NO TRADE.

In plain English
VWAP tells it whether price is trading above or below the fair intraday average.

ATR helps size the stop-loss and profit targets based on volatility.

Swing high / swing low are used to place the stop behind the recent move.

RSI filter helps confirm momentum if turned on.

Labels mark the chart with BUY or SELL when conditions are met.

How it behaves
It gives a BUY when price is strong, above VWAP, and momentum supports the move.

It gives a SELL when price is weak, below VWAP, and momentum supports the downside.

If neither setup is valid, it shows NO TRADE.

What the lines mean
Entry = the signal price.

Stop = where the trade idea is invalidated.

TP1 = first profit target.

TP2 = second profit target.

So overall, it is a chart-based ETH trade signal tool that tries to show cleaner short-term setups instead of every small price move.

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
var string status = "NO TRADE"

if longTrig
    entryLine := close
    stopLine := swingLow - buffer
    tp1Line := close + atrVal
    tp2Line := close + atrVal * 2
    status := "BUY"
    if showLabels
        label.new(bar_index, low - buffer, "BUY", style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.small)

if shortTrig
    entryLine := close
    stopLine := swingHigh + buffer
    tp1Line := close - atrVal
    tp2Line := close - atrVal * 2
    status := "SELL"
    if showLabels
        label.new(bar_index, high + buffer, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

if not longTrig and not shortTrig
    status := "NO TRADE"

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
    txt = "Status: " + status + "\n" +
          "ATR: " + str.tostring(atrVal, format.mintick) + "\n" +
          "VWAP: " + str.tostring(vwapVal, format.mintick) + "\n" +
          "Entry: " + str.tostring(entryLine, format.mintick) + "\n" +
          "Stop: " + str.tostring(stopLine, format.mintick) + "\n" +
          "TP1: " + str.tostring(tp1Line, format.mintick) + "\n" +
          "TP2: " + str.tostring(tp2Line, format.mintick)
    info := label.new(bar_index, high, txt, style=label.style_label_left, textcolor=color.white, color=color.new(color.blue, 60))
````
