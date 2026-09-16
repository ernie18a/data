<!-- tradingview-pine-id: PUB;7d549d25a6dc43f8a03a9d2e218908be -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Previous N Periods High/Low Rays

Source: https://www.tradingview.com/script/4jYRVtSi-Previous-N-Periods-High-Low-Rays/

## Description

Overview
The Previous N Periods High/Low Rays indicator is a clean, powerful tool designed to help traders automatically identify and visualize key support and resistance levels from past trading periods.

Instead of manually drawing horizontal lines at previous daily, weekly, or intraday highs and lows, this indicator does the heavy lifting for you. It plots infinite horizontal rays right from the exact candle that formed the extreme high or low of your chosen period, giving you precise visual references for future price action.

Key Features

Pinpoint Accuracy: The horizontal rays do not just start at the beginning of the period; they originate from the exact specific candle that created the high or low. This makes it incredibly easy to see exactly when the extreme level was established.

Infinite Extension: The rays extend infinitely to the right, acting as strong historical support and resistance zones as price develops.

Static & Reliable: The indicator specifically ignores the current forming period. It waits for a period to fully close before plotting its levels, ensuring the lines on your chart are locked in and will never repaint.

Keeps Charts Clean: By default, it only plots the rays for the last 5 periods. As a new period completes, the oldest lines are automatically deleted to prevent chart clutter.

Customizable Settings
Every aspect of this indicator can be tailored to fit your trading style via the Settings menu:

Time Period: Default is set to 1 Day, but you can easily change this to any timeframe you trade (e.g., 15 minutes, 1 Hour, 1 Week, 1 Month).

Number of Previous Periods: Default is 5 to keep the chart clean, but you can increase or decrease this number to track as many past periods as you need.

Styling: The default look is an opaque black line, but you can fully customize the line color, opaqueness, and thickness to match your chart theme.

How to Use It in Your Trading

Liquidity Sweeps: Use previous period highs and lows to spot where stop-losses are likely resting. Watch for price to sweep these rays and reverse.

Breakout Trading: Use the rays as trigger lines. A strong candle close above a previous period's high or below its low can signal a continuation.

Session Trading: Drop to a lower timeframe (like 5m) and set the indicator timeframe to 1D to easily trade intraday price action reacting to previous daily highs and lows.

(Note: Best used as part of a broader trading strategy. Ensure you adjust the indicator settings to fit the specific asset and timeframe you are analyzing.)

---

## Source Code

````pine
//@version=6
indicator("Previous N Periods High/Low Rays", overlay=true)

// =========================================================================
// INPUTS
// =========================================================================
tf = input.timeframe("1D", title="Time Period")
// Changed the default value here from 10 to 5
lookback = input.int(5, title="Number of Previous Periods", minval=1)

// Color and Style Inputs
lineColor = input.color(color.new(color.black, 0), title="Line Color & Opaqueness")
lineWidth = input.int(2, title="Line Thickness (Whole numbers only)", minval=1, maxval=10)

// =========================================================================
// VARIABLES & TRACKING
// =========================================================================
// Arrays to keep track of the lines so we can delete the old ones
var array<line> highLines = array.new_line()
var array<line> lowLines  = array.new_line()

// Variables to track the highest/lowest price and their specific bar index for the CURRENT period
var float curHigh = na
var int   curHighBar = na
var float curLow = na
var int   curLowBar = na

// =========================================================================
// LOGIC
// =========================================================================
isNewPeriod = ta.change(time(tf)) > 0

if isNewPeriod
    // 1. A new period just started. Plot the rays for the finished period.
    if not na(curHigh)
        // Plot horizontal ray from the specific candle of the highest point
        hLine = line.new(x1=curHighBar, y1=curHigh, x2=curHighBar + 1, y2=curHigh, 
                         extend=extend.right, color=lineColor, width=lineWidth)
        
        // Plot horizontal ray from the specific candle of the lowest point
        lLine = line.new(x1=curLowBar, y1=curLow, x2=curLowBar + 1, y2=curLow, 
                         extend=extend.right, color=lineColor, width=lineWidth)
        
        // Add these new lines to our arrays
        array.push(highLines, hLine)
        array.push(lowLines, lLine)
        
        // If we have more lines than the user's lookback setting, delete the oldest ones
        if array.size(highLines) > lookback
            line.delete(array.shift(highLines))
        if array.size(lowLines) > lookback
            line.delete(array.shift(lowLines))

    // 2. Reset the tracking variables for the new period (starting with this current candle)
    curHigh := high
    curHighBar := bar_index
    curLow := low
    curLowBar := bar_index

else
    // We are still inside the current period. Update the highest/lowest if necessary.
    if na(curHigh)
        // Edge case for the very first bar on the chart
        curHigh := high
        curHighBar := bar_index
        curLow := low
        curLowBar := bar_index
    else
        // Check for new High
        if high > curHigh
            curHigh := high
            curHighBar := bar_index
            
        // Check for new Low
        if low < curLow
            curLow := low
            curLowBar := bar_index
````
