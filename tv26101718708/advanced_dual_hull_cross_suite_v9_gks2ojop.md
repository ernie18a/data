# Advanced Dual Hull Cross Suite V9

- url: https://www.tradingview.com/script/gKs2ojOP-Advanced-Dual-Hull-Cross-Suite-V9/
- type: indicator
- pine_id: PUB;40d2823d2d66489280c1e864ef2df85e
- version: 1.0

## Description

Overview
The Dual Hull Cross Suite is an advanced trend-following and momentum indicator designed to provide high-precision entry and exit signals. By utilizing two distinct variations of the Hull Moving Average (HMA), this script captures trend shifts with significantly less lag than traditional moving averages.

How It Works
The indicator plots two customizable Hull lines that change color dynamically based on their current slope (rising vs. falling).

Fast Signal Line (Default: THMA 16): Uses the Triple Hull Moving Average (THMA) logic. This variation is engineered for extreme responsiveness, "snapping" to price action to identify early momentum shifts.

Slow Baseline (Default: HMA 14): Uses the Standard Hull Moving Average (HMA). This serves as the trend confirmation baseline.

Key Features
Dual-Variation Logic: Choose between HMA, EHMA (Exponential), and THMA for each line to suit your trading style.

Precision Crossovers: Clear BUY/SELL labels appear the moment the Fast Line crosses the Slow Baseline.

Slope-Based Coloring: Lines shift color instantly as their direction changes, providing an early warning before the actual crossover occurs.

Highly Customizable: Independent controls for line thickness, visibility, and color schemes for both bullish and bearish states.

Built-In Alerts: Optimized for Pine Script V6, including dynamic alert messages for real-time notifications.

Trading Signals
Bullish Entry (BUY): When the Fast Line (THMA) crosses above the Slow Baseline (HMA).

Bearish Entry (SELL): When the Fast Line (THMA) crosses below the Slow Baseline (HMA).

Trend Strength: Wide separation between the lines indicates strong momentum, while narrowing lines suggest a potential exhaustion or reversal.

## Source Code

````pine
//@version=6
indicator("Advanced Dual Hull Cross Suite V9", overlay=true)

// ==========================================
// FUNCTIONS
// ==========================================
method hma(float src, int length) => 
    ta.wma(2 * ta.wma(src, length / 2) - ta.wma(src, length), math.round(math.sqrt(length)))

method ehma(float src, int length) => 
    ta.ema(2 * ta.ema(src, length / 2) - ta.ema(src, length), math.round(math.sqrt(length)))

method thma(float src, int length) => 
    ta.wma(ta.wma(src, length / 3) * 3 - ta.wma(src, length / 2) - ta.wma(src, length), length)

get_hull(string mode, float src, int len) =>
    switch mode
        "Hma"  => src.hma(len)
        "Ehma" => src.ehma(len)
        "Thma" => src.thma(len / 2)
        => na

// ==========================================
// INPUTS
// ==========================================
group1 = "Suite 1 (Slow/Base)"
src1   = input.source(close, "Source", group=group1)
mode1  = input.string("Hma", "Variation", options=["Hma", "Thma", "Ehma"], group=group1)
len1   = input.int(14, "Length", group=group1)
vis1   = input.bool(true, "Show Suite 1?", group=group1)
colU1  = input.color(#00ff00, "Color Up", group=group1)
colD1  = input.color(#ff0000, "Color Down", group=group1)
thick1 = input.int(2, "Thickness", minval=1, maxval=5, group=group1)

group2 = "Suite 2 (Fast/Cross)"
src2   = input.source(close, "Source", group=group2)
mode2  = input.string("Thma", "Variation", options=["Hma", "Thma", "Ehma"], group=group2)
len2   = input.int(16, "Length", group=group2)
vis2   = input.bool(true, "Show Suite 2?", group=group2)
colU2  = input.color(#00bcd4, "Color Up", group=group2)
colD2  = input.color(#e91e63, "Color Down", group=group2)
thick2 = input.int(2, "Thickness", minval=1, maxval=5, group=group2)

// ==========================================
// LOGIC & CALCULATIONS
// ==========================================
mhull1  = get_hull(mode1, src1, len1)
c_line1 = mhull1 > mhull1[1] ? colU1 : colD1

mhull2  = get_hull(mode2, src2, len2)
c_line2 = mhull2 > mhull2[1] ? colU2 : colD2

buySignal  = ta.crossover(mhull2, mhull1)
sellSignal = ta.crossunder(mhull2, mhull1)

// ==========================================
// VISUALS & RENDERING
// ==========================================
plot(vis1 ? mhull1 : na, "Suite 1 Line", color=c_line1, linewidth=thick1)
plot(vis2 ? mhull2 : na, "Suite 2 Line", color=c_line2, linewidth=thick2)

// Precision Placement: Using location.absolute at the Hull Price level
// We use a conditional to only plot on the cross bar, otherwise 'na'
plotshape(buySignal ? mhull2 : na,  "Buy",  shape.labelup,   location.absolute, color.new(color.green, 0), 0, "BUY",  color.white, size=size.small)
plotshape(sellSignal ? mhull2 : na, "Sell", shape.labeldown, location.absolute, color.new(color.red, 0),   0, "SELL", color.white, size=size.small)

// Alert triggers
if buySignal
    alert("Bullish Cross: Suite 2 crossed above Suite 1", alert.freq_once_per_bar_close)
if sellSignal
    alert("Bearish Cross: Suite 2 crossed below Suite 1", alert.freq_once_per_bar_close)
````
