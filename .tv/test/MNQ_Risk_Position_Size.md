<!-- tradingview-pine-id: PUB;9a42a15ec82c4fbfa6dc86cafa2c94f1 -->
<!-- tradingviewscripts-format: 1 -->
# MNQ Risk Position Size

Source: https://www.tradingview.com/script/vQGywLgO-MNQ-Risk-Position-Size/

## Description

position sizing mnq. bullish candles, stop at bottom entry at close tells you have many micros to use based on how much you want to risk, opposite for bearish

---

## Source Code

````pine
 //@version=6
indicator("MNQ Risk Position Size", overlay=true)

riskDollars = input.float(1000, "Risk ($)")
pointValue = 2.0 // MNQ = $2 per point

bullish = close > open
bearish = close < open

// Store signals
var label[] signalLabels = array.new<label>()
var int signalCount = 0

// Function to remove oldest signal after 2 newer signals
removeOldSignal() =>
    if array.size(signalLabels) > 2
        old = array.shift(signalLabels)
        label.delete(old)

// Bullish Signal
if bullish
    stopDistance = close - low
    riskPerMicro = stopDistance * pointValue
    micros = stopDistance > 0 ? math.floor(riskDollars / riskPerMicro) : na

    newLabel = label.new(
         bar_index,
         low,
         str.tostring(micros),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.large)

    array.push(signalLabels, newLabel)
    removeOldSignal()

// Bearish Signal
if bearish
    stopDistance = high - close
    riskPerMicro = stopDistance * pointValue
    micros = stopDistance > 0 ? math.floor(riskDollars / riskPerMicro) : na

    newLabel = label.new(
         bar_index,
         high,
         str.tostring(micros),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.large)

    array.push(signalLabels, newLabel)
    removeOldSignal()
````
