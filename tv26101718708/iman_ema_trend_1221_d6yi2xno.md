# IMAN EMA TREND 12/21

- url: https://www.tradingview.com/script/d6Yi2xNo-IMAN-EMA-TREND-12-21/
- type: indicator
- pine_id: PUB;04f61c430588463fa70be8584df64af1
- version: 1.0

## Description

IMAN 12/21 EMA Trend Zone

The IMAN 12/21 EMA Trend Zone is a trend-following indicator built around the 12-period and 21-period Exponential Moving Averages (EMAs). It helps traders identify trend direction, dynamic support and resistance, pullback opportunities, and potential early reversal signals.

How It Works
Bullish Trend (Green):
The 12 EMA is above the 21 EMA.
Both EMAs turn green.
The EMA zone acts as dynamic support.
Bearish Trend (Red):
The 12 EMA is below the 21 EMA.
Both EMAs turn red.
The EMA zone acts as dynamic resistance.
Trend Signals
Green crossover signal when the 12 EMA crosses above the 21 EMA.
Red crossover signal when the 12 EMA crosses below the 21 EMA.
Support & Resistance Zone

The area between the 12 EMA and 21 EMA forms a dynamic trend zone.

In an uptrend, pullbacks into the EMA zone may provide support.
In a downtrend, pullbacks into the EMA zone may provide resistance.
Early Reversal Warnings
During an uptrend, a close below both EMAs may indicate weakening momentum and a potential bearish reversal.
During a downtrend, a close above both EMAs may indicate weakening bearish momentum and a potential bullish reversal.
Best Use

This indicator works best in trending markets and can be combined with price action, market structure, and volume analysis for higher-probability trade setups.

## Source Code

````pine
//@version=6
indicator("IMAN EMA TREND 12/21", overlay=true)

// ==========================
// USER SETTINGS
// ==========================

// EMA Lengths
fastLength = input.int(12, "Fast EMA Length")
slowLength = input.int(21, "Slow EMA Length")

// Colors
bullColor = input.color(#4caf50, "Bullish Color")
bearColor = input.color(#ff0000, "Bearish Color")

// Display Options
showFill = input.bool(true, "Show EMA Zone Fill")
showCrossArrows = input.bool(true, "Show Cross Arrows")
showReversalWarnings = input.bool(true, "Show Reversal Warnings")

// Line Thickness
lineWidth = input.int(2, "EMA Thickness", minval=1, maxval=5)

// ==========================
// EMA CALCULATIONS
// ==========================

ema12 = ta.ema(close, fastLength)
ema21 = ta.ema(close, slowLength)

// Trend Direction
bullish = ema12 > ema21
bearish = ema12 < ema21

// Dynamic Color
trendColor = bullish ? bullColor : bearColor

// ==========================
// EMA PLOTS
// ==========================

p1 = plot(ema12,
     color=trendColor,
     linewidth=lineWidth,
     title="Fast EMA")

p2 = plot(ema21,
     color=trendColor,
     linewidth=lineWidth,
     title="Slow EMA")

// EMA Zone Fill
fillColor = showFill ? color.new(trendColor, 85) : na
fill(p1, p2, color=fillColor)

// ==========================
// CROSS SIGNALS
// ==========================

bullCross = ta.crossover(ema12, ema21)
bearCross = ta.crossunder(ema12, ema21)

plotshape(showCrossArrows and bullCross,
     title="Bullish Cross",
     location=location.belowbar,
     style=shape.triangleup,
     color=bullColor,
     size=size.small)

plotshape(showCrossArrows and bearCross,
     title="Bearish Cross",
     location=location.abovebar,
     style=shape.triangledown,
     color=bearColor,
     size=size.small)

// ==========================
// REVERSAL WARNINGS
// ==========================

bullReversalWarning = bullish and close < ema12 and close < ema21
bearReversalWarning = bearish and close > ema12 and close > ema21

plotshape(showReversalWarnings and bullReversalWarning,
     title="Possible Bear Reversal",
     location=location.abovebar,
     style=shape.xcross,
     color=color.orange,
     size=size.tiny)

plotshape(showReversalWarnings and bearReversalWarning,
     title="Possible Bull Reversal",
     location=location.belowbar,
     style=shape.xcross,
     color=color.aqua,
     size=size.tiny)

// ==========================
// ALERTS
// ==========================

alertcondition(bullCross,
     title="Bullish EMA Cross",
     message="Fast EMA crossed above Slow EMA")

alertcondition(bearCross,
     title="Bearish EMA Cross",
     message="Fast EMA crossed below Slow EMA")

alertcondition(bullReversalWarning,
     title="Bullish Trend Warning",
     message="Price closed below EMA zone")

alertcondition(bearReversalWarning,
     title="Bearish Trend Warning",
     message="Price closed above EMA zone")
````
