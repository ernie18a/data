# Fundamentals of Liquidity & Trend Filter v2

- url: https://www.tradingview.com/script/INgKf7Rc-Fundamentals-of-Liquidity-Trend-Filter-v2/
- type: indicator
- pine_id: PUB;ecf65f837bfe474f81c87ea062705bad
- version: 1.0

## Description

Here is the amended TradingView Pine Script v6 indicator.

The previous version highlighted the background, but this updated script actively draws horizontal liquidity boxes directly on the chart, which act as visual representations of liquidity pools or dense order book zones. It also explicitly plots the fast Exponential Moving Average (EMA) and slow Simple Moving Average (SMA) lines and ensures they are highly visible.  

What is new in this version:
Explicit EMA/SMA Plots: The fast EMA and slow SMA are drawn with thicker lines to ensure they overlay clearly on top of the price candles. The SMA helps filter out microstructure noise, while the EMA tracks immediate momentum.  

Horizontal Liquidity Zones: Instead of coloring the background, the script now draws dynamic horizontal boxes around the price action (from the highest high to the lowest low) whenever the market enters a high-liquidity regime.

Liquidity Percentages: Inside each horizontal box, the script dynamically updates and displays the peak "Relative Liquidity %" achieved during that specific liquidity zone, allowing you to gauge the density of the volume pool supporting that price level.

## Source Code

````pine
//@version=6
indicator("Fundamentals of Liquidity & Trend Filter v2", overlay=true, max_boxes_count=500)

// =========================================================================
// INPUTS - Highly Customizable
// =========================================================================
grp_liq = "Liquidity % Parameters"
volLen = input.int(20, "Volume Baseline Length", minval=1, group=grp_liq, tooltip="Lookback period to determine average volume.")
liqThreshold = input.float(150.0, "High Liquidity % Threshold", minval=1.0, group=grp_liq, tooltip="Requires current volume to be this percentage of the average to be considered 'Liquid' (e.g., 150 = 150% of average volume).")

grp_ma = "Moving Average Settings"
fastLen = input.int(9, "Fast EMA Length", minval=1, group=grp_ma)
slowLen = input.int(21, "Slow SMA Length", minval=1, group=grp_ma)

grp_visuals = "Visuals"
boxColor = input.color(color.new(color.teal, 85), "Liquidity Box Fill Color", group=grp_visuals)
boxBorder = input.color(color.teal, "Liquidity Box Border", group=grp_visuals)

// =========================================================================
// CALCULATIONS
// =========================================================================
// 1. Moving Averages
fastMA = ta.ema(close, fastLen)
slowMA = ta.sma(close, slowLen)

// 2. Liquidity Percentage Metric
avgVol = ta.sma(volume, volLen)
float volPct = avgVol != 0 ? (volume / avgVol) * 100 : 0

// Explicit boolean check for Pine Script v6 strict typing
bool isHighlyLiquid = volPct >= liqThreshold

// =========================================================================
// HORIZONTAL LIQUIDITY ZONES (BOXES) & PERCENTAGES
// =========================================================================
var box liqBox = na
var float maxVolPct = 0.0
var float boxTop = na
var float boxBot = na

bool startLiquid = isHighlyLiquid and not isHighlyLiquid[1]
bool stayLiquid = isHighlyLiquid and isHighlyLiquid[1]

// When a new high liquidity zone starts, create a new box
if startLiquid
    boxTop := high
    boxBot := low
    maxVolPct := volPct
    liqBox := box.new(left=bar_index, top=boxTop, right=bar_index, bottom=boxBot, border_color=boxBorder, bgcolor=boxColor, text=str.tostring(math.round(maxVolPct)) + "%", text_color=boxBorder, text_size=size.small, text_halign=text.align_right)

// While we remain in the high liquidity zone, extend the box to the right and expand its height if necessary
if stayLiquid and not na(liqBox)
    boxTop := math.max(boxTop, high)
    boxBot := math.min(boxBot, low)
    
    // Track the peak liquidity percentage for this specific zone
    if volPct > maxVolPct
        maxVolPct := volPct
        
    box.set_top(liqBox, boxTop)
    box.set_bottom(liqBox, boxBot)
    box.set_right(liqBox, bar_index)
    box.set_text(liqBox, str.tostring(math.round(maxVolPct)) + "%")

// =========================================================================
// PLOTTING & SIGNALS
// =========================================================================
// Plot the Moving Averages distinctly on the chart
plot(fastMA, color=color.blue, linewidth=2, title="Fast EMA")
plot(slowMA, color=color.orange, linewidth=2, title="Slow SMA")

// Only trigger crossovers during high liquidity to prevent whipsaw traps
bool bullCross = ta.crossover(fastMA, slowMA) and isHighlyLiquid
bool bearCross = ta.crossunder(fastMA, slowMA) and isHighlyLiquid

plotshape(bullCross, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Liquid Bullish Signal")
plotshape(bearCross, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Liquid Bearish Signal")
````
