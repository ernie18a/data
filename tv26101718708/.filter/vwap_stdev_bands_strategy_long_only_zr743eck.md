# VWAP Stdev Bands Strategy (Long Only)

- url: https://www.tradingview.com/script/zr743ECk-VWAP-Stdev-Bands-Strategy-Long-Only/
- type: strategy
- pine_id: PUB;1cd3f4398c554f4ebb68f5fb2bca788d
- version: 1.0

## Description

The VWAP Stdev Bands Strategy (Long Only) is designed to identify potential long entry points in trending markets by utilizing the Volume Weighted Average Price (VWAP) and standard deviation bands. This strategy focuses on capturing upward price movements, leveraging statistical measures to determine optimal buy conditions.

Key Features:

VWAP Calculation: The strategy calculates the VWAP, which represents the average price a security has traded at throughout the day, weighted by volume. This is an essential indicator for determining the overall market trend.

Standard Deviation Bands: Two bands are created above and below the VWAP, calculated using specified standard deviations. These bands act as dynamic support and resistance levels, providing insight into price volatility and potential reversal points.

Trading Logic:

Long Entry Condition: A long position is triggered when the price crosses below the lower standard deviation band and then closes above it, signaling a potential price reversal to the upside.
Profit Target: The strategy allows users to set a predefined profit target, closing the long position once the specified target is reached.
Time Gap Between Orders: A customizable time gap can be specified to prevent multiple orders from being placed in quick succession, allowing for a more controlled trading approach.
Visualization: The VWAP and standard deviation bands are plotted on the chart with distinct colors, enabling traders to visually assess market conditions. The strategy also provides optional plotting of the previous day's VWAP for added context.

Use Cases:

Ideal for traders looking to engage in long-only positions within trending markets.
Suitable for intraday trading strategies or longer-term approaches based on market volatility.
Customization Options:

Users can adjust the standard deviation values, profit target, and time gap to tailor the strategy to their specific trading style and market conditions.
Note: As with any trading strategy, it is important to conduct thorough backtesting and analysis before live trading. Market conditions can change, and past performance does not guarantee future results.

## Source Code

````pine
//@version=5 
strategy("VWAP Stdev Bands Strategy (Long Only)", overlay=true)

// Standard Deviation Inputs
devUp1 = input.float(1.28, title="Stdev above (1)")
devDn1 = input.float(1.28, title="Stdev below (1)")

// Show Options
showPrevVWAP = input(false, title="Show previous VWAP close?")
profitTarget = input.float(2, title="Profit Target ($)", minval=0) // Profit target for closing orders
gapMinutes = input.int(15, title="Gap before new order (minutes)", minval=0) // Gap for placing new orders

// VWAP Calculation
var float vwapsum = na
var float volumesum = na
var float v2sum = na
var float prevwap = na // Track the previous VWAP
var float lastEntryPrice = na // Track the last entry price
var int lastEntryTime = na // Track the time of the last entry

start = request.security(syminfo.tickerid, "D", time)
newSession = ta.change(start)

vwapsum := newSession ? hl2 * volume : vwapsum[1] + hl2 * volume
volumesum := newSession ? volume : volumesum[1] + volume
v2sum := newSession ? volume * hl2 * hl2 : v2sum[1] + volume * hl2 * hl2

myvwap = vwapsum / volumesum
dev = math.sqrt(math.max(v2sum / volumesum - myvwap * myvwap, 0))

// Calculate Upper and Lower Bands
lowerBand1 = myvwap - devDn1 * dev
upperBand1 = myvwap + devUp1 * dev

// Plot VWAP and Bands with specified colors
plot(myvwap, style=plot.style_line, title="VWAP", color=color.green, linewidth=1)
plot(upperBand1, style=plot.style_line, title="VWAP Upper (1)", color=color.blue, linewidth=1)
plot(lowerBand1, style=plot.style_line, title="VWAP Lower (1)", color=color.red, linewidth=1)

// Trading Logic (Long Only)
longCondition = close < lowerBand1 and close[1] >= lowerBand1 // Price crosses below the lower band

// Get the current time in minutes
currentTime = timestamp("GMT-0", year(timenow), month(timenow), dayofmonth(timenow), hour(timenow), minute(timenow))

// Check if it's time to place a new order based on gap
canPlaceNewOrder = na(lastEntryTime) or (currentTime - lastEntryTime) >= gapMinutes * 60 * 1000

// Close condition based on profit target
if (strategy.position_size > 0)
    if (close - lastEntryPrice >= profitTarget)
        strategy.close("B")
        lastEntryTime := na // Reset last entry time after closing

// Execute Long Entry
if (longCondition and canPlaceNewOrder)
    strategy.entry("B", strategy.long)
    lastEntryPrice := close // Store the entry price
    lastEntryTime := currentTime // Update the last entry time

    // Add label for the entry
    label.new(bar_index, close, "B", style=label.style_label_down, color=color.green, textcolor=color.white, size=size.small)

// Optional: Plot previous VWAP for reference
prevwap := newSession ? myvwap[1] : prevwap[1]
plot(showPrevVWAP ? prevwap : na, style=plot.style_circles, color=close > prevwap ? color.green : color.red)
````
