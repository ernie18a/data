# ETH VWAP ATR Scalper Pro Stats

- url: https://www.tradingview.com/script/Wiytz7PE-ETH-VWAP-ATR-Scalper-Pro-Stats/
- type: indicator
- pine_id: PUB;3e628524592147069a103726e1f35b10
- version: 1.0

## Description

What the upgraded script should include
BUY / SELL signals on candle close.

Entry line.

Stop line.

TP1 line.

TP2 line.

Separate long and short win rates.

Alerts.

A stats table.

Best practice
Use this as a scalping helper, not as an exact predictor. Even strong-looking signals can fail, so the win-rate table is useful only as historical feedback

## Source Code

````pine
//@version=5
indicator("ETH VWAP ATR Scalper Pro Stats", overlay=true, max_labels_count=500)

lenAtr = input.int(14, "ATR Length")
lookback = input.int(5, "Swing Lookback")
useRsi = input.bool(true, "Use RSI Filter")
rsiLen = input.int(14, "RSI Length")
tp1Mult = input.float(1.0, "TP1 ATR Mult", step=0.1)
tp2Mult = input.float(2.0, "TP2 ATR Mult", step=0.1)
showLabels = input.bool(true, "Show Labels")
showStats = input.bool(true, "Show Stats")

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
var int dir = 0
var int totalLong = 0
var int totalShort = 0
var int winLong = 0
var int winShort = 0
var int lossLong = 0
var int lossShort = 0
var bool active = false

if longTrig
    dir := 1
    entryLine := close
    stopLine := swingLow - buffer
    tp1Line := close + atrVal * tp1Mult
    tp2Line := close + atrVal * tp2Mult
    active := true
    totalLong += 1

if shortTrig
    dir := -1
    entryLine := close
    stopLine := swingHigh + buffer
    tp1Line := close - atrVal * tp1Mult
    tp2Line := close - atrVal * tp2Mult
    active := true
    totalShort += 1

hitStop = active and ((dir == 1 and low <= stopLine) or (dir == -1 and high >= stopLine))
hitTp2 = active and ((dir == 1 and high >= tp2Line) or (dir == -1 and low <= tp2Line))
hitTp1 = active and not hitTp2 and ((dir == 1 and high >= tp1Line) or (dir == -1 and low <= tp1Line))

if hitTp2 or hitTp1
    if dir == 1
        winLong += 1
    if dir == -1
        winShort += 1
    active := false
    dir := 0

if hitStop
    if dir == 1
        lossLong += 1
    if dir == -1
        lossShort += 1
    active := false
    dir := 0

longRate = totalLong > 0 ? (winLong * 100.0 / totalLong) : na
shortRate = totalShort > 0 ? (winShort * 100.0 / totalShort) : na

plot(vwapVal, "VWAP", color=color.orange, linewidth=2)
plot(entryLine, "Entry", color=color.blue, linewidth=2, style=plot.style_linebr)
plot(stopLine, "Stop", color=color.red, linewidth=2, style=plot.style_linebr)
plot(tp1Line, "TP1", color=color.green, linewidth=2, style=plot.style_linebr)
plot(tp2Line, "TP2", color=color.teal, linewidth=2, style=plot.style_linebr)

plotshape(showLabels and longTrig, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY")
plotshape(showLabels and shortTrig, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

alertcondition(longTrig, title="Long Signal", message="ETH VWAP ATR Scalper Pro Stats: BUY")
alertcondition(shortTrig, title="Short Signal", message="ETH VWAP ATR Scalper Pro Stats: SELL")

var table stats = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast and showStats
    table.cell(stats, 0, 0, "Long Sig")
    table.cell(stats, 1, 0, str.tostring(totalLong))
    table.cell(stats, 0, 1, "Long Win")
    table.cell(stats, 1, 1, str.tostring(winLong))
    table.cell(stats, 0, 2, "Long %")
    table.cell(stats, 1, 2, na(longRate) ? "na" : str.tostring(longRate, format.mintick) + "%")
    table.cell(stats, 0, 3, "Short Sig")
    table.cell(stats, 1, 3, str.tostring(totalShort))
    table.cell(stats, 0, 4, "Short Win")
    table.cell(stats, 1, 4, str.tostring(winShort))
    table.cell(stats, 0, 5, "Short %")
    table.cell(stats, 1, 5, na(shortRate) ? "na" : str.tostring(shortRate, format.mintick) + "%")
````
