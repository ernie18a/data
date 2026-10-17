# Double Bollinger Bands (EMA/WMA Channels + SMA20)

- url: https://www.tradingview.com/script/OVKeIKx0-Double-Bollinger-Bands-EMA-WMA-Channels-SMA20/
- type: indicator
- pine_id: PUB;6adb52a28d644092a61544cb89418c1b
- version: 2.0

## Description

This indicator plots two Bollinger Band-style channels using different moving averages to provide a clearer view of price structure and volatility.

The first channel is based on an EMA (Exponential Moving Average) and represents the primary, more responsive trend.
The second channel uses a WMA (Weighted Moving Average), offering a slightly smoother perspective on price movement.

Both channels are calculated using the standard deviation of price, creating dynamic upper and lower bands that expand during high volatility and contract during consolidation.

## Source Code

````pine
//@version=6
indicator("EMA/WMA Channels + SMA20 (Acid/Wine) 2.0", overlay=true)

// ===== Inputs =====
length = input.int(20, "Length")
mult   = input.float(2.0, "StdDev", step=0.1)

// Toggles
showGreen = input.bool(true, "Show Green Channel")
showRed   = input.bool(true, "Show Red Channel")

// ===== Colors =====
// Acid Green (for HIGH channel)
acidLine = color.rgb(170, 255, 0)
acidFill = color.new(acidLine, 75)

// Wine / Prune (for LOW channel)
wineLine = color.rgb(128, 0, 64)        // deep wine
wineFill = color.new(wineLine, 75)      // soft fill

smaColor = color.rgb(255, 165, 0)
lineWidth = 1

// ===== SMA 20 =====
sma20 = ta.sma(close, length)
plot(sma20, color=smaColor, linewidth=lineWidth, title="SMA 20")

// ===== GREEN (HIGH-based) =====
g_basisEMA = ta.ema(high, length)
g_devEMA   = mult * ta.stdev(high, length)
g_upperEMA = g_basisEMA + g_devEMA
g_lowerEMA = g_basisEMA - g_devEMA

g_basisWMA = ta.wma(high, length)
g_devWMA   = mult * ta.stdev(high, length)
g_upperWMA = g_basisWMA + g_devWMA
g_lowerWMA = g_basisWMA - g_devWMA

// ===== RED (LOW-based) =====
r_basisEMA = ta.ema(low, length)
r_devEMA   = mult * ta.stdev(low, length)
r_upperEMA = r_basisEMA + r_devEMA
r_lowerEMA = r_basisEMA - r_devEMA

r_basisWMA = ta.wma(low, length)
r_devWMA   = mult * ta.stdev(low, length)
r_upperWMA = r_basisWMA + r_devWMA
r_lowerWMA = r_basisWMA - r_devWMA

// ===== PLOTS =====
// Acid green (upper structure)
g_pUpperEMA = plot(showGreen ? g_upperEMA : na, color=acidLine, linewidth=lineWidth)
g_pLowerEMA = plot(showGreen ? g_lowerEMA : na, color=acidLine, linewidth=lineWidth)
g_pUpperWMA = plot(showGreen ? g_upperWMA : na, color=acidLine, linewidth=lineWidth)
g_pLowerWMA = plot(showGreen ? g_lowerWMA : na, color=acidLine, linewidth=lineWidth)

// Wine (lower structure)
r_pUpperEMA = plot(showRed ? r_upperEMA : na, color=wineLine, linewidth=lineWidth)
r_pLowerEMA = plot(showRed ? r_lowerEMA : na, color=wineLine, linewidth=lineWidth)
r_pUpperWMA = plot(showRed ? r_upperWMA : na, color=wineLine, linewidth=lineWidth)
r_pLowerWMA = plot(showRed ? r_lowerWMA : na, color=wineLine, linewidth=lineWidth)

// ===== FILLS =====
fill(g_pUpperEMA, g_pUpperWMA, color = showGreen ? acidFill : na)
fill(g_pLowerEMA, g_pLowerWMA, color = showGreen ? acidFill : na)

fill(r_pUpperEMA, r_pUpperWMA, color = showRed ? wineFill : na)
fill(r_pLowerEMA, r_pLowerWMA, color = showRed ? wineFill : na)
````
