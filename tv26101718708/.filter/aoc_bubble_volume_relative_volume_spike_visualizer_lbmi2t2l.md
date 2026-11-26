# AOC Bubble Volume Relative Volume Spike & Visualizer

- url: https://www.tradingview.com/script/lBmi2T2l-AOC-Bubble-Volume-Relative-Volume-Spike-Visualizer/
- type: indicator
- pine_id: PUB;69d849ed95634f8884d6266ddfdc0cc5
- version: 1.0

## Description

Visualize volume spikes directly on price with dynamic bubble mapping.

The indicator calculates:

Volume Ratio → current volume relative to its moving average
ATR-based offset → positions bubbles consistently above price
Candle direction → determines bubble color (bullish / bearish)

Key improvement:

Classification is based on raw volume ratio (uncapped), allowing accurate detection of extreme volume spikes
A separate visual cap system can be used for normalization without losing underlying data precision

Volume Classification

Volume intensity is divided into four tiers:

Tiny → low activity
Small → below average
Medium → above average
Big → high volume / spike

Thresholds are fully customizable, allowing adaptation to different markets and timeframes.

Key Features
Visual representation of relative volume strength
Detection of high-volume spikes and anomalies
Customizable thresholds and filters
Optional minimum volume filter to reduce noise
Built-in alert system for high-volume bullish and bearish events
Alerts

The indicator includes alerts for:

Bullish volume spikes
Bearish volume spikes
General high-volume conditions
How to use
Large bubbles → increased participation and attention
Trend + large bubbles → potential continuation
Range + volume spikes → possible exhaustion or fake breakout
Use alongside price structure for better context

## Source Code

````pine
//@version=5
indicator("AOC Bubble Chart Overlay V1.11", overlay=true, max_labels_count=500)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
volLen        = input.int(20, "Volume Average Length", minval=1)
atrLen        = input.int(14, "ATR Length", minval=1)
offsetAtr     = input.float(0.35, "Bubble Offset ATR", minval=0.05, step=0.05)

showBull      = input.bool(true, "Show Bull Bubbles")
showBear      = input.bool(true, "Show Bear Bubbles")

tinyTh        = input.float(0.70, "Tiny Threshold", minval=0.0, step=0.05)
smallTh       = input.float(1.10, "Small Threshold", minval=0.0, step=0.05)
mediumTh      = input.float(1.60, "Medium Threshold", minval=0.0, step=0.05)

minShowRatio  = input.float(0.00, "Minimum Volume Ratio To Show", minval=0.0, step=0.05)

// Optional visual cap (only for future visual scaling logic if needed)
visualCap     = input.float(3.00, "Visual Cap Ratio", minval=0.5, step=0.1)

//----------------------------------------------------
// Core Calculations
//----------------------------------------------------
atrValue = ta.atr(atrLen)
volAvg   = ta.sma(volume, volLen)

// Raw ratio = true classification source
volRatio = volAvg > 0 ? volume / volAvg : 1.0

// Capped ratio = optional visual normalization only
volVisual = math.max(0.0, math.min(visualCap, volRatio))

bullBar = close >= open
bearBar = close < open

bubbleY = high + atrValue * offsetAtr

showThis = ((bullBar and showBull) or (bearBar and showBear)) and volRatio >= minShowRatio
bubbleColor = bullBar ? color.lime : color.red

//----------------------------------------------------
// Volume Tiers (classification uses RAW volRatio)
//----------------------------------------------------
isTiny  = volRatio < tinyTh
isSmall = volRatio >= tinyTh and volRatio < smallTh
isMed   = volRatio >= smallTh and volRatio < mediumTh
isBig   = volRatio >= mediumTh

//----------------------------------------------------
// Bubble Plotting
//----------------------------------------------------
plotshape(showThis and isTiny  ? bubbleY : na, title="Bubble Tiny",  style=shape.circle, location=location.absolute, size=size.tiny,  color=color.new(bubbleColor, 15))
plotshape(showThis and isSmall ? bubbleY : na, title="Bubble Small", style=shape.circle, location=location.absolute, size=size.small, color=color.new(bubbleColor, 25))

plotshape(showThis and isMed   ? bubbleY : na, title="Bubble Med 1", style=shape.circle, location=location.absolute, size=size.small, color=color.new(bubbleColor, 45))
plotshape(showThis and isMed   ? bubbleY : na, title="Bubble Med 2", style=shape.circle, location=location.absolute, size=size.tiny,  color=color.new(bubbleColor, 0))

plotshape(showThis and isBig   ? bubbleY : na, title="Bubble Big 1", style=shape.circle, location=location.absolute, size=size.large, color=color.new(bubbleColor, 65))
plotshape(showThis and isBig   ? bubbleY : na, title="Bubble Big 2", style=shape.circle, location=location.absolute, size=size.small, color=color.new(bubbleColor, 5))

//----------------------------------------------------
// Alerts
//----------------------------------------------------
alertcondition(showThis and isBig and bullBar, title="Bull Volume Spike", message="AOC Bubble Chart Overlay: High bullish volume spike detected.")
alertcondition(showThis and isBig and bearBar, title="Bear Volume Spike", message="AOC Bubble Chart Overlay: High bearish volume spike detected.")
alertcondition(showThis and volRatio > mediumTh, title="High Volume Bubble", message="AOC Bubble Chart Overlay: High relative volume detected.")
````
