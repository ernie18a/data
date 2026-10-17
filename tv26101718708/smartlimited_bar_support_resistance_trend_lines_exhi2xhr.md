# Smart-Limited Bar Support & Resistance  + Trend Lines

- url: https://www.tradingview.com/script/EXHi2XhR-Smart-Limited-Bar-Support-Resistance-Trend-Lines/
- type: indicator
- pine_id: PUB;f59c718d51384d5f9d89b0f2c69d1dcf
- version: 1.0

## Description

# Smart-Limited Bar Support & Resistance  + Trend Lines

## Overview

Smart-Limited Bar S/R + Trend lines is a market structure indicator designed to automatically identify key support and resistance levels while drawing dynamic trend lines based on price action structure.

Unlike traditional indicators that rely solely on moving averages or lagging calculations, this tool focuses on actual market structure by tracking swing highs, swing lows, higher lows, and lower highs.

The indicator is designed to help traders quickly visualize:

- Current support and resistance levels
- Trend line-based support
- Trend line-based resistance
- Structural swing points
- Potential breakout areas

---

## Features

### Dynamic Support and Resistance

The indicator continuously monitors a user-defined look back period and identifies:

- Highest High (Resistance)
- Lowest Low (Support)

By default, the script uses the last 20 bars.

When a new high or low is established within the look back window, the support or resistance level is automatically updated.

When price breaks a support or resistance level, the horizontal line stops extending, allowing traders to clearly see where the level was invalidated.

---

### Structural Swing Detection

The indicator uses pivot-based market structure analysis to identify significant turning points.

A swing high is confirmed when price forms a local peak.

A swing low is confirmed when price forms a local bottom.

Users can adjust the Pivot Strength setting to control the sensitivity of swing detection.

Higher values:
- Fewer swings
- Stronger structure
- Cleaner trend lines

Lower values:
- More swings
- Faster reaction
- Increased sensitivity

---

### Resistance Trend Lines (Lower High Structure)

The indicator automatically identifies Lower High formations.

When a new confirmed swing high is lower than the previous swing high, a resistance trend line is drawn.

This helps traders identify:

- Downtrends
- Descending resistance
- Potential breakout zones

The trendline updates automatically as new lower highs form.

---

### Support Trend lines (Higher Low Structure)

The indicator automatically identifies Higher Low formations.

When a new confirmed swing low is higher than the previous swing low, a support trendline is drawn.

This helps traders identify:

- Uptrends
- Rising support
- Potential continuation zones

The trend line updates automatically as new higher lows form.

---

### Historical Validation

Before displaying a trend line, the indicator evaluates whether the line has already been violated by price action during the swing confirmation period.

This prevents the display of structurally invalid trend lines and improves chart clarity.

---

### Swing Point Visualization

Optional swing markers can be displayed on the chart.

Red markers:
- Confirmed Swing Highs

Green markers:
- Confirmed Swing Lows

These markers help traders visually inspect market structure and understand how trend lines are generated.

---

## Inputs

### Pivot Strength
Controls swing detection sensitivity.

Default: 10

Higher values create stronger, less frequent swing points.

---

### Support/Resistance Look back
Number of bars used to calculate support and resistance.

Default: 20

---

### Minimum Bars Between Swings
Filters nearby pivots to reduce noise.

Default: 10

---

### Show Swing Points
Displays or hides swing markers.

Default: Enabled

---

## Best Use Cases

This indicator is particularly useful for:

- Price Action Trading
- Swing Trading
- Trend Following
- Market Structure Analysis
- Breakout Trading
- Support and Resistance Trading

It can be applied to:

- Stocks
- Indexes
- Futures
- Forex
- Cryptocurrency

and works across all timeframes.

---

## Trading Notes

This indicator is intended to assist with market structure analysis and should not be considered a standalone trading system.

For best results, combine it with:

- Volume analysis
- Risk management
- Trend confirmation
- Multi-timeframe analysis

Always use proper position sizing and stop-loss management when trading live markets.


## Disclaimer

This indicator is provided for educational and informational purposes only. It is not financial, investment, or trading advice.

The indicator is designed to assist with market structure analysis by identifying support, resistance, swing points, and trendlines. No indicator can guarantee future market performance or profitable trading results.

Trading and investing involve substantial risk, including the potential loss of capital. Users should perform their own research, apply proper risk management, and consult a qualified financial professional before making investment decisions.

Use this indicator at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © pavanjayaram (Fixed by Gemini)

//@version=6
indicator("Smart-Limited Bar Support & Resistance  + Trend Lines", overlay=true, max_lines_count=500)

//==================================================
// INPUTS
//==================================================
pivotLen      = input.int(10, "Pivot Strength", minval=3)
srLen         = input.int(20, "SR Lookback")
minSwingBars  = input.int(10, "Min Bars Between Swings")
showSwings    = input.bool(true, "Show Swing Points")

//==================================================
// SUPPORT / RESISTANCE
//==================================================
highest20 = ta.highest(high, srLen)
lowest20  = ta.lowest(low, srLen)

var line resLine = na
var line supLine = na

if highest20 != highest20[1]
    if not na(resLine)
        line.delete(resLine)
    resLine := line.new(bar_index, highest20, bar_index + 1, highest20, extend = extend.right, color = color.red, width = 2)

if lowest20 != lowest20[1]
    if not na(supLine)
        line.delete(supLine)
    supLine := line.new(bar_index, lowest20, bar_index + 1, lowest20, extend = extend.right, color = color.lime, width = 2)

// Stop SR lines after breakout
if not na(resLine) and close > highest20
    line.set_extend(resLine, extend.none)
    line.set_x2(resLine, bar_index)

if not na(supLine) and close < lowest20
    line.set_extend(supLine, extend.none)
    line.set_x2(supLine, bar_index)

//==================================================
// STRUCTURAL SWING TRACKING
//==================================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHighPrice = na
var int   lastHighBar   = na
var float prevHighPrice = na
var int   prevHighBar   = na

var float lastLowPrice  = na
var int   lastLowBar    = na
var float prevLowPrice  = na
var int   prevLowBar    = na

var line downTrend = na
var line upTrend   = na

var bool downTrendBroken = false
var bool upTrendBroken   = false

//--------------------------------------------------
// LOWER HIGHS (Resistance Trendline)
//--------------------------------------------------
if not na(ph)
    newHighBar = bar_index - pivotLen
    
    if na(lastHighBar) or (newHighBar - lastHighBar >= minSwingBars)
        prevHighPrice := lastHighPrice
        prevHighBar   := lastHighBar
        
        lastHighPrice := ph
        lastHighBar   := newHighBar

        if not na(prevHighPrice) and lastHighPrice < prevHighPrice
            // Calculate historical breach before drawing
            bool historicalBreach = false
            int breachBar = na
            
            // Temporary line math to check if past bars broke it during confirmation window
            float slope = (lastHighPrice - prevHighPrice) / (lastHighBar - prevHighBar)
            
            for i = lastHighBar + 1 to bar_index
                float checkPrice = prevHighPrice + slope * (i - prevHighBar)
                if close[bar_index - i] > checkPrice
                    historicalBreach := true
                    breachBar := i
                    break

            if not na(downTrend)
                line.delete(downTrend)

            downTrend := line.new(
                prevHighBar,
                prevHighPrice,
                lastHighBar,
                lastHighPrice,
                extend = extend.right,
                color = color.orange,
                width = 3)


//--------------------------------------------------
// HIGHER LOWS (Support Trendline)
//--------------------------------------------------
if not na(pl)
    newLowBar = bar_index - pivotLen
    
    if na(lastLowBar) or (newLowBar - lastLowBar >= minSwingBars)
        prevLowPrice := lastLowPrice
        prevLowBar   := lastLowBar
        
        lastLowPrice := pl
        lastLowBar   := newLowBar

        if not na(prevLowPrice) and lastLowPrice > prevLowPrice
            // Calculate historical breach before drawing
            bool historicalBreach = false
            int breachBar = na
            
            float slope = (lastLowPrice - prevLowPrice) / (lastLowBar - prevLowBar)
            
            for i = lastLowBar + 1 to bar_index
                float checkPrice = prevLowPrice + slope * (i - prevLowBar)
                if close[bar_index - i] < checkPrice
                    historicalBreach := true
                    breachBar := i
                    break

            if not na(upTrend)
                line.delete(upTrend)

            upTrend := line.new(
                prevLowBar,
                prevLowPrice,
                lastLowBar,
                lastLowPrice,
                extend = extend.right,
                color = color.aqua,
                width = 3)

            if not na(upTrend)
                line.delete(upTrend)

            upTrend := line.new(
                 x1 = prevLowBar,
                 y1 = prevLowPrice,
                 x2 = lastLowBar,
                 y2 = lastLowPrice,
                 extend = historicalBreach ? extend.none : extend.right,
                 color = historicalBreach ? color.new(color.gray, 50) : color.aqua,
                 width = 3)
            
            if historicalBreach
                line.set_x2(upTrend, breachBar)
                upTrendBroken := true
            else
                upTrendBroken := false


//==================================================
// PLOTS
//==================================================
plotshape(showSwings and not na(ph), style=shape.circle, location=location.abovebar, color=color.red, size=size.tiny, offset=-pivotLen)
plotshape(showSwings and not na(pl), style=shape.circle, location=location.belowbar, color=color.lime, size=size.tiny, offset=-pivotLen)
````
