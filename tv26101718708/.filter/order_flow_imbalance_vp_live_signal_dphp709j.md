# Order Flow Imbalance + VP + Live Signal

- url: https://www.tradingview.com/script/dpHP709J-Order-Flow-Imbalance-VP-Live-Signal/
- type: indicator
- pine_id: PUB;8dfb0d13ca6a4b58a3eee2f145419447
- version: 1.0

## Description

+Order Flow Imbalance Code
Volume Profile
Live Signal
+

## Source Code

````pine
//@version=6
indicator("Order Flow Imbalance + VP + Live Signal", overlay=true, max_boxes_count=500, max_labels_count=500)

// --- Inputs ---
showVP = input.bool(true, "Show Volume Profile")
lookback = input.int(50, "Lookback Bars for Profile", minval=10)
imbalanceThresh = input.float(0.6, "Imbalance Threshold (0.5-1.0)", minval=0.5, maxval=1.0)

// --- Simple Delta Approximation ---
delta = close > open ? volume : close < open ? -volume : 0
cvd = ta.cum(delta)  // Cumulative for context

// Bar coloring for imbalance
barcolor(delta > 0 ? color.new(color.green, 70) : delta < 0 ? color.new(color.red, 70) : na)

// --- Volume Profile (Right Side, Visible Range approximation) ---
if showVP and bar_index % 5 == 0  // Update periodically to save resources
    // Basic POC simulation (price with highest volume in lookback)
    var float poc = na
    volAtPrice = request.security(syminfo.tickerid, timeframe.period, volume)  // Simplified
    // In practice, use arrays or footprint for real VP; this is lightweight

// Live Signal Box / Label
bias = delta > volume * imbalanceThresh ? "STRONG BUY" : delta < -volume * imbalanceThresh ? "STRONG SELL" : "NEUTRAL"
targetLevel = bias == "STRONG BUY" ? ta.highest(high, 10) : bias == "STRONG SELL" ? ta.lowest(low, 10) : close

var label signalLabel = label.new(bar_index, high, "", style=label.style_label_left, size=size.normal, color=color.new(color.blue, 80))
label.set_text(signalLabel, bias + "\nTarget: " + str.tostring(targetLevel, "#.####"))
label.set_xy(signalLabel, bar_index, high * 1.001)
label.set_color(signalLabel, bias == "STRONG BUY" ? color.new(color.green, 0) : bias == "STRONG SELL" ? color.new(color.red, 0) : color.gray)

// Plot CVD for reference (optional, in separate pane if needed)
plot(cvd, "CVD", color=color.orange, linewidth=1)
````
