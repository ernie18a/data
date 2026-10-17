# Buy and Sell Only Signals

- url: https://www.tradingview.com/script/HEi52rmA-Buy-and-Sell-Only-Signals/
- type: indicator
- pine_id: PUB;89b846c32df644b2a0261bd31b068ad2
- version: 1.0

## Description

Plan buy and sell
Plan buy and sell
Plan buy and sell
Plan buy and sell
Plan buy and sell
Plan buy and sell
Plan buy and sell
Plan buy and sell

## Source Code

````pine
//@version=5
indicator("11 MA Crosses 20 & 50 MA", overlay=true)

// === INPUTS ===
fastLen   = input.int(11, "Fast MA")
midLen    = input.int(20, "Middle MA")
slowLen   = input.int(50, "Slow MA")

slopeThreshold = input.float(0.0, "Slope Threshold", step=0.0001)

// === MOVING AVERAGES ===
fastMA = ta.sma(close, fastLen)
midMA  = ta.sma(close, midLen)
slowMA = ta.sma(close, slowLen)

// === SLOPES ===
fastSlope = fastMA - fastMA[1]
midSlope  = midMA - midMA[1]
slowSlope = slowMA - slowMA[1]

// === FLAT FILTER ===
notFlat = math.abs(fastSlope) > slopeThreshold and
           math.abs(midSlope)  > slopeThreshold and
           math.abs(slowSlope) > slopeThreshold

// =====================================================
// BUY CONDITION
// 11 MA crosses ABOVE both 20 MA and 50 MA
// =====================================================
buySignal =
     fastMA[1] < midMA[1] and
     fastMA[1] < slowMA[1] and
     fastMA > midMA and
     fastMA > slowMA and
     notFlat

// =====================================================
// SELL CONDITION
// 11 MA crosses BELOW both 20 MA and 50 MA
// =====================================================
sellSignal =
     fastMA[1] > midMA[1] and
     fastMA[1] > slowMA[1] and
     fastMA < midMA and
     fastMA < slowMA and
     notFlat

// === PLOTS ===
plot(fastMA, color=color.rgb(243, 33, 226), linewidth=2, title="11 MA")
plot(midMA,  color=color.green, linewidth=2, title="20 MA")
plot(slowMA, color=color.orange, linewidth=2, title="50 MA")

// === SIGNALS ===
plotshape(buySignal,title="Buy Signal",location=location.belowbar,style=shape.triangleup,color=color.lime,size=size.small,text="BUY")

plotshape(sellSignal,title="Sell Signal",location=location.abovebar,style=shape.triangledown,color=color.red,size=size.small,text="SELL")

// === ALERTS ===
alertcondition(buySignal,title="Buy Alert",message="BUY: 11 MA crossed ABOVE 20 MA and 50 MA")

alertcondition(sellSignal,title="Sell Alert",message="SELL: 11 MA crossed BELOW 20 MA and 50 MA")
````
