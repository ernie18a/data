<!-- tradingview-pine-id: PUB;f7f33f3f2e3342c0b3d82ef465e1a210 -->
<!-- tradingviewscripts-format: 1 -->
# Nifty Gann & Strike Levels

Source: https://www.tradingview.com/script/E0JnLKgM-Nifty-Gann-Strike-Levels-VDT/

## Description

Core FeaturesDynamic Gann Levels: The indicator calculates Gann square levels based on the current price. It takes the square root of the price ($\sqrt{\text{Price}}$) and increments it by $0.125$, which mathematically corresponds to the $45^\circ$ angle steps found in traditional Gann square charts (matching the PDF reference). It then plots a user-defined number of these levels above and below the current price, acting as hidden mathematical support and resistance zones.100-Interval Levels (Strike Prices): It automatically identifies the nearest multiple of 100 relative to the current price and draws horizontal lines at these intervals. For index options trading, these 100-point intervals represent major round-number psychological levels and standard options strike prices, where heavy open interest and institutional positioning typically occur.Previous Day High & Low: The script tracks the highest and lowest price points of the preceding trading session. These are widely considered two of the most critical reference points for intraday trading, often acting as strong pivot points, breakout triggers, or reversal zones for the current day.

---

## Source Code

````pine
//@version=6
indicator("Nifty Gann & Strike Levels", overlay = true, max_lines_count = 500)

// --- Enums & Methods ---
enum lineStyle
    solid = 'Solid'
    dashed = 'Dashed'
    dotted = 'Dotted'

method toPineStyle(lineStyle this) =>
    switch this
        lineStyle.solid => line.style_solid
        lineStyle.dashed => line.style_dashed
        lineStyle.dotted => line.style_dotted

// --- Inputs ---

// GANN LEVELS
grp_gann = "GANN LEVELS"
showGann = input.bool(true, "Show Gann Levels", group = grp_gann)
gannLevels = input.int(5, "Levels Above / Below", group = grp_gann)
gannColor = input.color(#313131, "Gann Line Color", group = grp_gann)
gannWidth = input.int(2, "Gann Line Width", group = grp_gann)
gannStyleIn = input.enum(lineStyle.solid, "Gann Line Style", group = grp_gann) 

// 100 INTERVAL LEVELS
grp_interval = "100 INTERVAL LEVELS"
showInterval = input.bool(true, "Show 100-Interval Levels", group = grp_interval)
intervalLevels = input.int(5, "Levels Above / Below", group = grp_interval)
intervalColor = input.color(#e0a94e, "100-Interval Color", group = grp_interval)
intervalWidth = input.int(2, "100-Interval Line Width", group = grp_interval)
intervalStyleIn = input.enum(lineStyle.dashed, "100-Interval Line Style", group = grp_interval) 

// PREVIOUS DAY LEVELS
grp_prev = "PREVIOUS DAY LEVELS"
showPrev = input.bool(true, "Show Prev Day High/Low", group = grp_prev)
prevHighColor = input.color(#ff5252, "Prev Day High Color", group = grp_prev)
prevLowColor = input.color(#4caf50, "Prev Day Low Color", group = grp_prev)
prevWidth = input.int(2, "Prev Day Line Width", group = grp_prev)
prevStyleIn = input.enum(lineStyle.dashed, "Prev Day Line Style", group = grp_prev)

// --- Core Logic & Calculations ---

// Calculate previous day High / Low
var float prevHigh = na
var float prevLow = na
var float currentHigh = high
var float currentLow = low

// CORRECTED: timeframe.change explicitly returns a boolean in v6
if timeframe.change("D")
    prevHigh := currentHigh
    prevLow := currentLow
    currentHigh := high
    currentLow := low
else
    currentHigh := math.max(currentHigh, high)
    currentLow := math.min(currentLow, low)

// Arrays to store line IDs for dynamic redrawing
var line[] gannLines = array.new_line()
var line[] intervalLines = array.new_line()
var line prevHighLine = na
var line prevLowLine = na

if barstate.islast
    // 1. Clean up old lines to prevent chart clutter
    if array.size(gannLines) > 0
        for i = 0 to array.size(gannLines) - 1
            line.delete(array.get(gannLines, i))
        array.clear(gannLines)
        
    if array.size(intervalLines) > 0
        for i = 0 to array.size(intervalLines) - 1
            line.delete(array.get(intervalLines, i))
        array.clear(intervalLines)
        
    if not na(prevHighLine)
        line.delete(prevHighLine)
    if not na(prevLowLine)
        line.delete(prevLowLine)
        
    // 2. Draw Gann Levels
    if showGann
        float anchorGannSqrt = math.sqrt(close)
        int baseStep = math.round(anchorGannSqrt / 0.125) 
        for i = -gannLevels to gannLevels
            float lvl = math.pow((baseStep + i) * 0.125, 2)
            line l = line.new(bar_index - 1, lvl, bar_index, lvl, extend = extend.both, color = gannColor, width = gannWidth, style = gannStyleIn.toPineStyle())
            array.push(gannLines, l)
            
    // 3. Draw 100-Interval Levels (Strike Prices)
    if showInterval
        int baseInterval = math.round(close / 100) * 100
        for i = -intervalLevels to intervalLevels
            float lvl = baseInterval + (i * 100)
            line l = line.new(bar_index - 1, lvl, bar_index, lvl, extend = extend.both, color = intervalColor, width = intervalWidth, style = intervalStyleIn.toPineStyle())
            array.push(intervalLines, l)
            
    // 4. Draw Previous Day High/Low
    if showPrev and not na(prevHigh) and not na(prevLow)
        prevHighLine := line.new(bar_index - 1, prevHigh, bar_index, prevHigh, extend = extend.both, color = prevHighColor, width = prevWidth, style = prevStyleIn.toPineStyle())
        prevLowLine := line.new(bar_index - 1, prevLow, bar_index, prevLow, extend = extend.both, color = prevLowColor, width = prevWidth, style = prevStyleIn.toPineStyle())
````
