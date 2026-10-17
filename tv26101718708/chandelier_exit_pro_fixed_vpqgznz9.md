# Chandelier Exit PRO (Fixed)

- url: https://www.tradingview.com/script/VPqgZNz9-Chandelier-Exit-PRO-Fixed/
- type: indicator
- pine_id: PUB;f235f7ed64eb47a6bb9b0e2d50d65664
- version: 1.0

## Description

This script is a trend-following trading indicator that:

Uses ATR (volatility) to create dynamic stop levels
Detects trend direction changes (uptrend / downtrend)
Generates BUY signals when trend turns bullish
Generates SELL signals when trend turns bearish
Uses ADX to avoid sideways markets and reduce false signals

## Source Code

````pine
//@version=6
indicator('Chandelier Exit PRO (Fixed)', shorttitle='CE PRO+', overlay=true)

// ================= INPUTS =================
length = input.int(22, title='ATR Period')
mult = input.float(3.0, step=0.1, title='ATR Multiplier')
useClose = input.bool(true, title='Use Close Price')

adxThreshold = input.int(20, title='ADX Trend Strength')

// ================= CORE =================
atr = mult * ta.atr(length)

// ================= MANUAL ADX =================
lengthADX = 14

upMove = high - high[1]
downMove = low[1] - low

plusDM = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

tr = ta.tr(true)
atrADX = ta.rma(tr, lengthADX)

plusDI = 100 * ta.rma(plusDM, lengthADX) / atrADX
minusDI = 100 * ta.rma(minusDM, lengthADX) / atrADX

dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, lengthADX)

isTrending = adx > adxThreshold

// ================= STOPS =================
longStop = (useClose ? ta.highest(close, length) : ta.highest(length)) - atr
longStopPrev = nz(longStop[1], longStop)
longStop := close[1] > longStopPrev ? math.max(longStop, longStopPrev) : longStop

shortStop = (useClose ? ta.lowest(close, length) : ta.lowest(length)) + atr
shortStopPrev = nz(shortStop[1], shortStop)
shortStop := close[1] < shortStopPrev ? math.min(shortStop, shortStopPrev) : shortStop

// ================= DIRECTION =================
var int dir = 1
dir := close > shortStopPrev ? 1 : close < longStopPrev ? -1 : dir

// ================= SIGNALS =================
buySignal = dir == 1 and dir[1] == -1 and isTrending
sellSignal = dir == -1 and dir[1] == 1 and isTrending

// ================= PLOTS =================
plot(dir == 1 ? longStop : na, color=color.green, linewidth=2)
plot(dir == -1 ? shortStop : na, color=color.red, linewidth=2)

plotshape(buySignal, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sellSignal, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")
````
