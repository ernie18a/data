# Multi Timeframe Stochastic RSI

- url: https://www.tradingview.com/script/mwKz7moQ/
- type: indicator
- pine_id: PUB;9a9f141ddb4a4651aec38e1cd3b01098
- version: 2.0

## Description

方向性一致で背景色が変わります

## Source Code

````pine
//@version=6
indicator("MTF StochRSI Direction Agreement", shorttitle="MTF StochRSI", overlay=false)

// ===== Inputs =====
rsiLength   = input.int(14, "RSI Length", minval=1)
stochLength = input.int(14, "Stoch Length", minval=1)
kLength     = input.int(3, "K Smoothing", minval=1)
dLength     = input.int(3, "D Smoothing", minval=1)

tf1 = input.timeframe("15", "Higher TF 1")
tf2 = input.timeframe("60", "Higher TF 2")

// ===== Function =====
f_stoch_rsi() =>
    rsiValue = ta.rsi(close, rsiLength)

    lowestRSI  = ta.lowest(rsiValue, stochLength)
    highestRSI = ta.highest(rsiValue, stochLength)

    stochRsi = highestRSI != lowestRSI ?
         (rsiValue - lowestRSI) / (highestRSI - lowestRSI) * 100 : 0

    k = ta.sma(stochRsi, kLength)
    d = ta.sma(k, dLength)

    [k, d]

// ===== Current TF =====
[curK, curD] = f_stoch_rsi()

// ===== Higher TFs =====
[tf1K, tf1D] = request.security(
     syminfo.tickerid,
     tf1,
     f_stoch_rsi())

[tf2K, tf2D] = request.security(
     syminfo.tickerid,
     tf2,
     f_stoch_rsi())

// ===== Direction =====
bullCurrent = curK > curD
bullTF1     = tf1K > tf1D
bullTF2     = tf2K > tf2D

bearCurrent = curK < curD
bearTF1     = tf1K < tf1D
bearTF2     = tf2K < tf2D

allBull = bullCurrent and bullTF1 and bullTF2
allBear = bearCurrent and bearTF1 and bearTF2

// ===== Background =====
bgcolor(
     allBull ? color.new(color.green, 85) :
     allBear ? color.new(color.red, 85) :
     na)

// ===== Levels =====
hline(80, "Overbought", color=color.red)
hline(20, "Oversold", color=color.lime)
hline(50, "Middle", color=color.gray)

// ===== Current TF =====
plot(curK, "Current K", color=color.blue, linewidth=2)
plot(curD, "Current D", color=color.aqua)

// ===== HTF1 =====
plot(tf1K, "HTF1 K", color=color.orange, linewidth=2)
plot(tf1D, "HTF1 D", color=color.yellow)

// ===== HTF2 =====
plot(tf2K, "HTF2 K", color=color.purple, linewidth=2)
plot(tf2D, "HTF2 D", color=color.fuchsia)

// ===== Optional Markers =====
plotshape(
     allBull,
     title="Bull Agreement",
     style=shape.triangleup,
     location=location.bottom,
     color=color.green,
     size=size.tiny)

plotshape(
     allBear,
     title="Bear Agreement",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.tiny)
````
