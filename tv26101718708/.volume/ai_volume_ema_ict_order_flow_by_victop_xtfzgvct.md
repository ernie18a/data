# AI Volume + EMA + ICT Order Flow by Victop

- url: https://www.tradingview.com/script/xtFzgvct-AI-Volume-EMA-ICT-Order-Flow-by-Victop/
- type: indicator
- pine_id: PUB;456e0ae34c0845b3b33d2e28187b4911
- version: 1.0

## Description

You only buy/sell whenever you see a breakout of strong buy/sell signals

## Source Code

````pine
//@version=6
indicator("AI Volume + EMA + ICT Order Flow", overlay=true, max_labels_count=500)

// =====================
// EMA SETTINGS
// =====================
ema5 = ta.ema(close, 5)
ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)

plot(ema5, "EMA 5", color=color.green, linewidth=2)
plot(ema9, "EMA 9", color=color.blue, linewidth=2)
plot(ema20, "EMA 20", color=color.red, linewidth=2)

// =====================
// TREND CONDITIONS
// =====================
bullTrend = ema5 > ema9 and ema9 > ema20
bearTrend = ema5 < ema9 and ema9 < ema20

// =====================
// BREAKOUT CHANNEL
// =====================
channelLength = input.int(20, "Channel Length")

upperChannel = ta.highest(high, channelLength)
lowerChannel = ta.lowest(low, channelLength)

plot(upperChannel, "Upper Channel", color=color.lime)
plot(lowerChannel, "Lower Channel", color=color.maroon)

bullBreakout = close > upperChannel[1]
bearBreakout = close < lowerChannel[1]

// =====================
// VOLUME SENTIMENT
// =====================
volLength = input.int(20, "Volume Average")

avgVol = ta.sma(volume, volLength)

highVolume = volume > avgVol * 1.5

bullVolume = highVolume and close > open
bearVolume = highVolume and close < open

// =====================
// ICT STYLE BOS
// =====================
swingHigh = ta.highest(high, 10)
swingLow = ta.lowest(low, 10)

bullBOS = close > swingHigh[1]
bearBOS = close < swingLow[1]

// =====================
// SCORE SYSTEM
// =====================
buyScore = 0
buyScore += bullTrend ? 1 : 0
buyScore += bullBreakout ? 1 : 0
buyScore += bullVolume ? 1 : 0
buyScore += bullBOS ? 1 : 0

sellScore = 0
sellScore += bearTrend ? 1 : 0
sellScore += bearBreakout ? 1 : 0
sellScore += bearVolume ? 1 : 0
sellScore += bearBOS ? 1 : 0

strongBuy = buyScore >= 4
strongSell = sellScore >= 4

buySignal = buyScore == 3
sellSignal = sellScore == 3

// =====================
// CHART COLORS
// =====================
bgcolor(bullTrend ? color.new(color.green, 92) : na)
bgcolor(bearTrend ? color.new(color.red, 92) : na)

// =====================
// SIGNALS
// =====================
plotshape(strongBuy,
     title="Strong Buy",
     location=location.belowbar,
     color=color.lime,
     style=shape.labelup,
     text="STRONG BUY")

plotshape(strongSell,
     title="Strong Sell",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="STRONG SELL")

plotshape(buySignal and not strongBuy,
     title="Buy",
     location=location.belowbar,
     color=color.green,
     style=shape.triangleup,
     size=size.small)

plotshape(sellSignal and not strongSell,
     title="Sell",
     location=location.abovebar,
     color=color.orange,
     style=shape.triangledown,
     size=size.small)

// =====================
// ALERTS
// =====================
alertcondition(strongBuy,
     title="Strong Buy Alert",
     message="Strong Buy Signal Detected")

alertcondition(strongSell,
     title="Strong Sell Alert",
     message="Strong Sell Signal Detected")
````
