# Bullish Ichimoku Reclaim Screener

- url: https://www.tradingview.com/script/A8e1kAmF-Bullish-Ichimoku-Reclaim-Screener/
- type: indicator
- pine_id: PUB;1f48aae28f224a33a2bf9e6074c66318
- version: 1.0

## Description

Screener for: 
Established uptrend
Temporary pullback / consolidation
Momentum re-acceleration via Ichimoku conversion line reclaim

## Source Code

````pine
//@version=5
indicator("Bullish Ichimoku Reclaim Screener", overlay=true)

// === Moving Averages ===
ma50 = ta.sma(close, 50)
ma100 = ta.sma(close, 100)
ma200 = ta.sma(close, 200)

// === Ichimoku Conversion Line / Tenkan-Sen ===
tenkanLength = 9
tenkan = (ta.highest(high, tenkanLength) + ta.lowest(low, tenkanLength)) / 2

// === Uptrend Conditions ===
above50 = close > ma50
above100 = close > ma100
above200 = close > ma200
maAlignment = ma50 > ma100

uptrend = above50 and above100 and above200 and maAlignment

// === Pullback Below Conversion Line ===
belowTenkan = close < tenkan

barsBelow = 0
barsBelow := belowTenkan ? nz(barsBelow[1]) + 1 : 0

wasBelow5Bars = barsBelow[1] >= 5

// === Bullish Cross Back Above Conversion Line ===
bullishCross = ta.crossover(close, tenkan)

// === Final Signal ===
strongSignal = uptrend and wasBelow5Bars and bullishCross

// === Plotting ===
plot(ma50, color=color.blue, title="50 MA")
plot(ma100, color=color.orange, title="100 MA")
plot(ma200, color=color.gray, title="200 MA")
plot(tenkan, color=color.red, title="Ichimoku Conversion Line")

plotshape(strongSignal,
     title="Bullish Reclaim",
     location=location.belowbar,
     color=color.lime,
     style=shape.triangleup,
     size=size.small,
     text="Reclaim")

// === Alerts ===
alertcondition(strongSignal,
     title="Bullish Ichimoku Reclaim",
     message="Stock crossed back above the Ichimoku conversion line after 5+ days below it while above the 50, 100, and 200 day moving averages.")
````
