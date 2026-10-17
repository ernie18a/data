# Normalized Momentum Trigger Simple

- url: https://www.tradingview.com/script/lGjO9eHM-Normalized-Momentum-Trigger-Simple/
- type: indicator
- pine_id: PUB;c45b77664e44425d98b453a235c4ceab
- version: 1.0

## Description

Normalized Momentum Trigger Simple

Normalized Momentum Trigger is a clean momentum and impulse indicator designed to identify directional shifts by measuring how far price is moving away from its average, normalized by recent volatility.

Instead of using raw momentum alone, this indicator standardizes price movement relative to its recent deviation, helping make momentum behavior easier to compare across different symbols and timeframes.

Features:

• Normalized momentum line
• Impulse histogram
• Bullish and bearish trigger levels
• Extreme bull and extreme bear trigger levels
• Multiple moving average basis options:

• SMA
• EMA
• WMA
• RMA
• HMA

• Optional zero-line filter
• Optional momentum slope confirmation
• Optional trend MA filter
• Background bias coloring
• Bull, bear, extreme bull, and extreme bear markers

Alerts Included:

• Bull Trigger
• Bear Trigger
• Extreme Bull Trigger
• Extreme Bear Trigger
• Momentum Crossed Above Zero
• Momentum Crossed Below Zero

Potential use cases:

• Identify momentum shifts
• Spot impulse changes
• Confirm trend continuation
• Filter trade entries
• Detect early changes in directional pressure
• Add confluence to existing systems

Interpretation:

Bull Trigger
Momentum impulse crosses above the bullish threshold.

Bear Trigger
Momentum impulse crosses below the bearish threshold.

Extreme Bull / Bear Trigger
Momentum impulse reaches a stronger threshold, suggesting more aggressive directional movement.

Zero Line
Momentum above zero suggests bullish pressure, while momentum below zero suggests bearish pressure.

Impulse Histogram
Shows the change in normalized momentum and helps visualize acceleration or deceleration.

About TrendGenY Indicator

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Normalized Momentum Trigger Simple", shorttitle="NMT", overlay=false, precision=3)

//====================================================
// Inputs
//====================================================
grpSource = "Source & Core"
src            = input.source(close, "Source", group=grpSource)
basisLen       = input.int(20, "Basis Length", minval=1, group=grpSource)
normLen        = input.int(20, "Normalization Length", minval=5, group=grpSource)
smoothLen      = input.int(3, "Impulse Smoothing", minval=1, group=grpSource)

grpBasis = "Basis Type"
basisType      = input.string("SMA", "Basis MA", options=["SMA", "EMA", "WMA", "RMA", "HMA"], group=grpBasis)

grpTrigger = "Trigger Thresholds"
bullTrig       = input.float(0.25, "Bull Trigger", step=0.01, group=grpTrigger)
bearTrig       = input.float(-0.25, "Bear Trigger", step=0.01, group=grpTrigger)
extremeBull    = input.float(0.60, "Extreme Bull Trigger", step=0.01, group=grpTrigger)
extremeBear    = input.float(-0.60, "Extreme Bear Trigger", step=0.01, group=grpTrigger)

grpFilter = "Optional Filters"
useZeroLineFilter   = input.bool(true, "Require Momentum Above/Below Zero", group=grpFilter)
useSlopeFilter      = input.bool(false, "Require Momentum Slope Confirmation", group=grpFilter)
useTrendFilter      = input.bool(false, "Require Price vs Trend MA Filter", group=grpFilter)
trendLen            = input.int(50, "Trend MA Length", minval=1, group=grpFilter)
trendType           = input.string("EMA", "Trend MA Type", options=["SMA", "EMA", "WMA", "RMA", "HMA"], group=grpFilter)

grpDisplay = "Display"
showNormMomentum = input.bool(true, "Show Normalized Momentum", group=grpDisplay)
showHistogram    = input.bool(true, "Show Impulse Histogram", group=grpDisplay)
showSignals      = input.bool(true, "Show Trigger Markers", group=grpDisplay)
showBackground   = input.bool(false, "Show Background Bias", group=grpDisplay)

//====================================================
// MA Function
//====================================================
ma(_src, _len, _type) =>
    float result = na
    if _type == "SMA"
        result := ta.sma(_src, _len)
    else if _type == "EMA"
        result := ta.ema(_src, _len)
    else if _type == "WMA"
        result := ta.wma(_src, _len)
    else if _type == "RMA"
        result := ta.rma(_src, _len)
    else if _type == "HMA"
        result := ta.hma(_src, _len)
    result

//====================================================
// Core Calculations
//====================================================
basis = ma(src, basisLen, basisType)
dev   = ta.stdev(src, normLen)

// normalized momentum = how far price is from basis in stdev units
normMomentumRaw = dev != 0 ? (src - basis) / dev : 0.0
normMomentum    = ta.ema(normMomentumRaw, 1)

// impulse = change in normalized momentum
impulseRaw = normMomentum - normMomentum[1]
impulse    = smoothLen > 1 ? ta.ema(impulseRaw, smoothLen) : impulseRaw

//====================================================
// Trend Filter
//====================================================
trendMA = ma(src, trendLen, trendType)

bullTrendOk = not useTrendFilter or src > trendMA
bearTrendOk = not useTrendFilter or src < trendMA

//====================================================
// Additional Filters
//====================================================
bullZeroOk = not useZeroLineFilter or normMomentum > 0
bearZeroOk = not useZeroLineFilter or normMomentum < 0

bullSlopeOk = not useSlopeFilter or normMomentum > normMomentum[1]
bearSlopeOk = not useSlopeFilter or normMomentum < normMomentum[1]

//====================================================
// Trigger Logic
//====================================================
bullTrigger = ta.crossover(impulse, bullTrig) and bullZeroOk and bullSlopeOk and bullTrendOk
bearTrigger = ta.crossunder(impulse, bearTrig) and bearZeroOk and bearSlopeOk and bearTrendOk

extremeBullTrigger = ta.crossover(impulse, extremeBull) and bullZeroOk and bullSlopeOk and bullTrendOk
extremeBearTrigger = ta.crossunder(impulse, extremeBear) and bearZeroOk and bearSlopeOk and bearTrendOk

// continuation / bias conditions
bullBias = impulse > 0 and normMomentum > 0
bearBias = impulse < 0 and normMomentum < 0

//====================================================
// Colors
//====================================================
histColor =
     impulse >= extremeBull ? color.orange :
     impulse > bullTrig ? color.green :
     impulse <= extremeBear ? color.orange :
     impulse < bearTrig ? color.red :
     color.gray

momColor =
     normMomentum > 0 ?
         normMomentum > normMomentum[1] ? color.green : color.lime
     :
         normMomentum < normMomentum[1] ? color.red : color.orange

bgBiasColor =
     bullBias ? color.new(color.green, 90) :
     bearBias ? color.new(color.red, 90) :
     na

//====================================================
// Plots
//====================================================
hline(0, "Zero", color=color.gray)
hline(bullTrig, "Bull Trigger", color=color.new(color.green, 50))
hline(bearTrig, "Bear Trigger", color=color.new(color.red, 50))
hline(extremeBull, "Extreme Bull", color=color.new(color.orange, 40))
hline(extremeBear, "Extreme Bear", color=color.new(color.orange, 40))

plot(showNormMomentum ? normMomentum : na, title="Normalized Momentum", color=momColor, linewidth=2)
plot(showHistogram ? impulse : na, title="Impulse Histogram", style=plot.style_histogram, linewidth=3, color=histColor)

bgcolor(showBackground ? bgBiasColor : na)

//====================================================
// Trigger Markers
//====================================================
plotshape(showSignals and bullTrigger, title="Bull Trigger", style=shape.triangleup, location=location.bottom, color=color.green, size=size.small, text="Bull")
plotshape(showSignals and bearTrigger, title="Bear Trigger", style=shape.triangledown, location=location.top, color=color.red, size=size.small, text="Bear")
plotshape(showSignals and extremeBullTrigger, title="Extreme Bull Trigger", style=shape.circle, location=location.bottom, color=color.orange, size=size.small, text="XB")
plotshape(showSignals and extremeBearTrigger, title="Extreme Bear Trigger", style=shape.circle, location=location.top, color=color.orange, size=size.small, text="XS")

//====================================================
// Alerts
//====================================================
alertcondition(bullTrigger, title="Bull Trigger", message="Normalized Momentum Trigger: Bull trigger on {{ticker}} {{interval}}")
alertcondition(bearTrigger, title="Bear Trigger", message="Normalized Momentum Trigger: Bear trigger on {{ticker}} {{interval}}")
alertcondition(extremeBullTrigger, title="Extreme Bull Trigger", message="Normalized Momentum Trigger: Extreme bull trigger on {{ticker}} {{interval}}")
alertcondition(extremeBearTrigger, title="Extreme Bear Trigger", message="Normalized Momentum Trigger: Extreme bear trigger on {{ticker}} {{interval}}")
alertcondition(ta.crossover(normMomentum, 0), title="Momentum Crossed Above Zero", message="Normalized Momentum Trigger: Momentum crossed above zero on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(normMomentum, 0), title="Momentum Crossed Below Zero", message="Normalized Momentum Trigger: Momentum crossed below zero on {{ticker}} {{interval}}")
````
