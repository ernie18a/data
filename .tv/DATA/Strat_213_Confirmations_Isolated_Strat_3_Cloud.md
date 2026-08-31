<!-- tradingview-pine-id: PUB;0977d8a4d72a4c94814e4d8297bf727d -->
<!-- tradingviewscripts-format: 1 -->
# Strat 2/1/3 + Confirmations & Isolated Strat 3 Cloud

Source: https://www.tradingview.com/script/vpq4yvN9-Strat-2-1-3-Confirmations-Isolated-Strat-3-Cloud/

## Description

This script is based off the 312 strat! it also has a shaded box around the 3 to identify better.

---

## Source Code

````pine
//@version=6
indicator("Strat 2/1/3 + Confirmations & Isolated Strat 3 Cloud", overlay=true, linktoseries=true)

// ---------------- Inputs ----------------
showInside       = input.bool(true, "Show Inside Bars (1)")
showOutside      = input.bool(true, "Show Outside Bars (3)")
channelLength    = input.int(50, "Channel Length")
showChannel      = input.bool(true, "Show Price Channels")
higherTF         = input.timeframe("W", "Higher Timeframe Trend")
rsiLength        = input.int(14, "RSI Length")
macdFastLength   = input.int(12, "MACD Fast Length")
macdSlowLength   = input.int(26, "MACD Slow Length")
macdSignalLength = input.int(9, "MACD Signal Length")

// ---------------- Candlestick Relationships ----------------
insideBar  = high < high[1] and low > low[1]
twoUp      = high > high[1] and low >= low[1]
twoDown    = low < low[1] and high <= high[1]
outsideBar = high > high[1] and low < low[1]

// ---------------- Volume & A/D Confirmation ----------------
vol = volume
avgVol = ta.sma(volume, 20)
adUp   = close > open and vol > avgVol
adDown = close < open and vol > avgVol

// ---------------- Higher-Timeframe Trend ----------------
HTF_close = request.security(syminfo.tickerid, higherTF, close)
HTF_MA50  = request.security(syminfo.tickerid, higherTF, ta.sma(close, 50))
HTF_Uptrend   = HTF_close > HTF_MA50
HTF_Downtrend = HTF_close < HTF_MA50

// ---------------- RSI & MACD ----------------
rsi = ta.rsi(close, rsiLength)
[macdValue, macdSignal, _] = ta.macd(close, macdFastLength, macdSlowLength, macdSignalLength)

// ---------------- Confirmation Logic ----------------
volConfirmUp   = twoUp and vol > avgVol and adUp and rsi > 50 and macdValue > macdSignal
volConfirmDown = twoDown and vol > avgVol and adDown and rsi < 50 and macdValue < macdSignal

// ---------------- 2-2 Reversal Detection ----------------
twoTwoUpReversal   = twoDown[1] and twoUp and volConfirmUp and HTF_Uptrend
twoTwoDownReversal = twoUp[1] and twoDown and volConfirmDown and HTF_Downtrend

// ---------------- Candle Recoloring ----------------
barColor = twoTwoUpReversal ? color.white : twoTwoDownReversal ? color.fuchsia : na
barcolor(barColor)

// ---------------- Plot Shapes/Labels for 2s, 1s, 3s ----------------
plotshape(twoTwoUpReversal, title="2C-RV Up", style=shape.labelup, location=location.belowbar, color=color.green, text="2C-RV", textcolor=color.white, size=size.tiny)
plotshape(twoTwoDownReversal, title="2C-RV Down", style=shape.labeldown, location=location.abovebar, color=color.red, text="2C-RV", textcolor=color.white, size=size.tiny)

plotshape(twoUp and not twoTwoUpReversal, title="2 Up", style=shape.labelup, location=location.belowbar, color=color.green, text="2", textcolor=color.white, size=size.tiny)
plotshape(twoDown and not twoTwoDownReversal, title="2 Down", style=shape.labeldown, location=location.abovebar, color=color.red, text="2", textcolor=color.white, size=size.tiny)

plotshape(showInside and insideBar, title="Inside Bar (1)", style=shape.labelup, location=location.belowbar, color=color.purple, text="1", textcolor=color.white, size=size.tiny)
plotshape(showOutside and outsideBar, title="Outside Bar (3)", style=shape.labelup, location=location.belowbar, color=color.blue, text="3", textcolor=color.white, size=size.tiny)

// ---------------- Channels ----------------
channelHigh = ta.highest(high, channelLength)
channelLow  = ta.lowest(low, channelLength)
channelMid  = (channelHigh + channelLow) / 2.0

plot(showChannel ? channelHigh : na, color=color.yellow, style=plot.style_line, linewidth=2, title="Upper Channel")
plot(showChannel ? channelLow : na, color=color.yellow, style=plot.style_line, linewidth=2, title="Lower Channel")
plot(showChannel ? channelMid : na, color=color.gray, style=plot.style_line, linewidth=1, title="Mid Channel")

// ---------------- Trade Entry Signals ----------------
longSignal  = twoTwoUpReversal and volConfirmUp and HTF_Uptrend and rsi > 50 and macdValue > macdSignal
shortSignal = twoTwoDownReversal and volConfirmDown and HTF_Downtrend and rsi < 50 and macdValue < macdSignal

plotshape(longSignal, title="LONG Entry", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.black, size=size.small)
plotshape(shortSignal, title="SHORT Entry", style=shape.triangledown, location=location.abovebar, color=color.fuchsia, text="SHORT", textcolor=color.white, size=size.small)

// ---------------- Isolated Strat 3 Region & Lines ----------------
var int active3 = 0
if outsideBar
    active3 := 1
else if active3 == 1 and (insideBar or (high <= high[1] and low >= low[1]))
    active3 := 1
else
    active3 := 0

var float s3_hi = na
var float s3_lo = na

if outsideBar
    s3_hi := high
    s3_lo := low
else if active3 == 0
    s3_hi := na
    s3_lo := na

p3_high = plot(s3_hi, color=color.yellow, linewidth=2, title="Strat 3 High", style=plot.style_linebr)
p3_low  = plot(s3_lo, color=color.yellow, linewidth=2, title="Strat 3 Low", style=plot.style_linebr)

fill(p3_high, p3_low, color=color.new(color.gray, 70), title="Strat 3 Cloud")
````
