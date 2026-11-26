# MTF MA & MACD & StochRSI (pro)

- url: https://www.tradingview.com/script/X4D4olag-MTF-MA-MACD-StochRSI-pro/
- type: indicator
- pine_id: PUB;15674f80950244e9aaad550e601febda
- version: 1.0

## Description

Multi-Timeframe MA & MACD & StochRSI (Pro)

The Multi-Timeframe MA & MACD & StochRSI (Pro) is a professional multi-timeframe confluence dashboard built to help traders quickly identify trend direction, momentum strength, and cross-timeframe alignment in one clean visual layout.

This tool combines Moving Averages, MACD logic, and StochRSI cross conditions across multiple timeframes, allowing traders to reduce chart clutter and improve decision-making without constantly switching between charts.

Designed for traders who rely on confluence, top-down analysis, and momentum confirmation.

Core Purpose

This indicator answers one key trading question:

Are my moving averages, momentum, and oscillator signals aligned across multiple timeframes?

By tracking multiple confirmations together, traders can identify stronger trend setups while filtering weaker or conflicting market conditions.

Multi-Timeframe Dashboard

The dashboard scans and displays data across:

1 Minute
5 Minute
15 Minute
1 Hour
4 Hour
1 Day
1 Week

This provides both short-term and higher-timeframe market alignment.

Core Features
1) Multi-Timeframe Moving Average Analysis

The indicator tracks:

20 EMA
50 EMA

For each timeframe it checks whether price is:

Above EMA → Bullish bias
Below EMA → Bearish bias

This gives a quick directional read of market structure.

2) MACD Confirmation Logic (Enhanced)

Unlike a basic MACD crossover, this version uses stricter logic for stronger confirmation.

Buy Condition
Histogram > 0
MACD Line > 0
Signal Line > 0
Sell Condition
Histogram ≤ 0
MACD Line ≤ 0
Signal Line ≤ 0
Neutral

If momentum is mixed, the dashboard displays Neutral.

This helps remove weaker crossover noise and improves momentum quality.

3) StochRSI Cross Confirmation

The dashboard tracks StochRSI cross alignment using:

RSI calculation
Stochastic range
Smoothed %K line
Smoothed %D line
Buy
%K > %D
Sell
%K < %D
Neutral
Flat or undefined conditions

This adds momentum confirmation beyond moving averages.

4) Non-Repainting Multi-Timeframe Logic

The script uses stable request.security() calls with completed timeframe bars to reduce repainting behaviour and improve consistency.

Useful for traders who want cleaner higher-timeframe confirmation.

5) On-Chart Moving Average Overlay

In addition to the dashboard, the indicator plots:

Current timeframe 20 EMA
Current timeframe 50 EMA

These allow traders to visually track trend support/resistance directly on price.

6) Weekly MA Overlay

Optional higher-timeframe moving averages can also be shown directly on the active chart:

Weekly 20 EMA
Weekly 50 EMA

This helps identify:

Macro trend direction
Dynamic support/resistance
Higher timeframe bias
Confluence zones

Can be toggled ON/OFF in settings.

7) Adjustable Table Text Size

The dashboard supports text scaling for cleaner viewing:

Tiny
Small
Normal
Large
Huge

Useful for different monitor sizes and chart layouts.

Colour Logic
Green

Bullish / Buy

Price above EMA
Positive MACD alignment
StochRSI Buy condition
Red

Bearish / Sell

Price below EMA
Negative MACD alignment
StochRSI Sell condition
Grey

Neutral / Mixed

No strong directional bias

This allows fast visual scanning across all timeframes.

Best Used For

This indicator is ideal for:

Multi-timeframe trend analysis
Momentum confirmation
Confluence trading
Swing trading
Intraday trading
Scalping
Breakout confirmation
Trend-following systems

Works well on:

Crypto
Forex
Indices
Stocks
Commodities
How to Use It
Step 1 – Check EMA Alignment

Look for price above or below the 20 and 50 EMA across multiple timeframes.

Step 2 – Confirm MACD Strength

Check whether MACD is fully aligned (not just crossing).

Step 3 – Confirm StochRSI Direction

Look for %K vs %D agreement.

Step 4 – Find Confluence

The strongest setups often occur when:

MA structure aligns
MACD aligns
StochRSI aligns
Higher timeframe bias supports the trade
Trading Framework Example

A strong bullish setup might show:

Price above 20 EMA
Price above 50 EMA
MACD Buy
StochRSI Buy
Weekly MA acting as support

A strong bearish setup may show the inverse.

Summary

Multi-Timeframe MA & MACD & StochRSI (Pro) is a high-confluence dashboard built for traders who want cleaner multi-timeframe trend analysis, stronger momentum confirmation, and faster market alignment in one professional workflow.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DigiDavesData

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0
// © davidholmes1992

//@version=6
indicator('MTF MA & MACD & StochRSI (pro)', shorttitle = 'MTFMACDStochRSI Stable Fixed', overlay = true)

// Inputs for Moving Averages
ma20Length = input(20, '20 MA Length')
ma50Length = input(50, '50 MA Length')

// Inputs for StochRSI
rsiLength = input.int(14, 'StochRSI RSI Length', minval = 1)
stochLength = input.int(14, 'StochRSI Stochastic Length', minval = 1)
kLength = input.int(3, '%K Length', minval = 1) // Fast line
dLength = input.int(3, '%D Length', minval = 1) // Slow line

// Input for Table Text Size
tableTextSizeInput = input.string('normal', 'Table Text Size', options = ['tiny', 'small', 'normal', 'large', 'huge'])

// Function to map text size input to text.size constant
getTableTextSize(size_str) =>
    if size_str == 'tiny'
        size.tiny
    else if size_str == 'small'
        size.small
    else if size_str == 'large'
        size.large
    else if size_str == 'huge'
        size.huge
    else // "normal" or any other value
        size.normal

// Get the actual text size to use for the table cells
currentTableTextSize = getTableTextSize(tableTextSizeInput)

// Function to get all necessary data for a given timeframe from the last completed bar
// This function will be called unconditionally for each timeframe.
get_timeframe_data(timeframe_str) =>
    // Define the expressions to be calculated on the requested timeframe's 'open' price.
    // This ensures all calculations are performed within the context of the target timeframe.
    open_tf_src = open

    // MA Calculations
    ema20_tf_calc = ta.ema(open_tf_src, ma20Length)
    ema50_tf_calc = ta.ema(open_tf_src, ma50Length)

    // MACD Calculations
    ema12_tf_calc = ta.ema(open_tf_src, 12)
    ema26_tf_calc = ta.ema(open_tf_src, 26)
    macdLine_calc = ema12_tf_calc - ema26_tf_calc
    signalLine_calc = ta.ema(macdLine_calc, 9)
    histogram_calc = macdLine_calc - signalLine_calc

    // StochRSI Calculations
    rsi_tf_calc = ta.rsi(open_tf_src, rsiLength)
    lowestRSI_tf_calc = ta.lowest(rsi_tf_calc, stochLength)
    highestRSI_tf_calc = ta.highest(rsi_tf_calc, stochLength)

    // Avoid division by zero for StochRSI %K. If range is zero, %K is na.
    k_tf_calc = if highestRSI_tf_calc - lowestRSI_tf_calc != 0
        (rsi_tf_calc - lowestRSI_tf_calc) / (highestRSI_tf_calc - lowestRSI_tf_calc) * 100
    else
        na // Use na when the range is zero to avoid undefined behavior

    k_smooth_tf_calc = ta.sma(k_tf_calc, kLength) // %K (Fast Line)
    d_smooth_tf_calc = ta.sma(k_smooth_tf_calc, dLength) // %D (Slow Line)

    // StochRSI Condition: %K vs %D - Determine the signal *before* request.security
    stochRsiCondition_calc = 'Neutral' // Default to Neutral
    stochRsiColor_calc = color.rgb(60, 60, 60) // Darker grey for Neutral

    // Check the current relationship between %K and %D for a continuous signal
    if not na(k_smooth_tf_calc) and not na(d_smooth_tf_calc)
        // Buy if %K is above %D
        if k_smooth_tf_calc > d_smooth_tf_calc
            stochRsiCondition_calc := 'Buy'
            stochRsiColor_calc := color.new(color.rgb(50, 150, 100), 30) // Muted Teal Green with transparency
            stochRsiColor_calc
        // Sell if %K is below %D
        else if k_smooth_tf_calc < d_smooth_tf_calc
            stochRsiCondition_calc := 'Sell'
            stochRsiColor_calc := color.new(color.rgb(150, 50, 50), 30) // Muted Rose Red with transparency
            stochRsiColor_calc

    // Request all calculated series and the pre-determined StochRSI signal in a single, non-conditional call from the specified timeframe.
    // By passing the full calculations here, request.security fetches their values directly
    // from the historical context of the target timeframe, ensuring stability and non-repainting.
    [open_req, ema20_req, ema50_req, macdLine_req, signalLine_req, histogram_req, stochRsiCondition_req, stochRsiColor_req] = request.security(syminfo.tickerid, timeframe_str, [open_tf_src, ema20_tf_calc, ema50_tf_calc, macdLine_calc, signalLine_calc, histogram_calc, stochRsiCondition_calc, stochRsiColor_calc], lookahead = barmerge.lookahead_off)

    // MA Conditions: check if open is above/below EMA
    condition20 = open_req > ema20_req ? 'Above' : 'Below'
    color20 = open_req > ema20_req ? color.new(color.rgb(50, 150, 100), 30) : color.new(color.rgb(150, 50, 50), 30) // Muted Teal Green/Rose Red with transparency
    condition50 = open_req > ema50_req ? 'Above' : 'Below'
    color50 = open_req > ema50_req ? color.new(color.rgb(50, 150, 100), 30) : color.new(color.rgb(150, 50, 50), 30) // Muted Teal Green/Rose Red with transparency

    // MACD Condition: check if histogram is above or below zero, AND both lines are on the correct side of zero
    // Buy if histogram > 0 AND both MACD Line and Signal Line are > 0
    // Sell if histogram <= 0 AND both MACD Line and Signal Line are <= 0
    macdCondition = if histogram_req > 0 and macdLine_req > 0 and signalLine_req > 0
        'Buy'
    else if histogram_req <= 0 and macdLine_req <= 0 and signalLine_req <= 0
        'Sell'
    else
        'Neutral' // Added a 'Neutral' state for cases that don't meet strict buy/sell criteria

    macdColor = if macdCondition == 'Buy'
        color.new(color.rgb(50, 150, 100), 30) // Muted Teal Green with transparency
    else if macdCondition == 'Sell'
        color.new(color.rgb(150, 50, 50), 30) // Muted Rose Red with transparency
    else
        color.rgb(60, 60, 60) // Darker grey for Neutral

    // StochRSI condition and color are now directly from the requested values
    [condition20, color20, condition50, color50, macdCondition, macdColor, stochRsiCondition_req, stochRsiColor_req]


// Initialize the table
int rows = 8 // 7 timeframes + header
int columns = 5 // Timeframe + 2 MAs + MACD + StochRSI
table tbl = table.new(position.top_right, rows, columns, bgcolor = color.rgb(20, 20, 20)) // Very dark grey background

// Add headers to the table
table.cell(tbl, 0, 0, 'Timeframe', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 0, 1, '20 MA Cross', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 0, 2, '50 MA Cross', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 0, 3, 'MACD Cross', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 0, 4, 'StochRSI Cross', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // New header

// 1 Minute Timeframe
[cond1Min20, color1Min20, cond1Min50, color1Min50, macdCond1, macdColor1, stochRsiCond1, stochRsiColor1] = get_timeframe_data('1')
table.cell(tbl, 1, 0, '1 Minute', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // Timeframe column to dark grey
table.cell(tbl, 1, 1, cond1Min20, bgcolor = color1Min20, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 1, 2, cond1Min50, bgcolor = color1Min50, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 1, 3, macdCond1, bgcolor = macdColor1, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 1, 4, stochRsiCond1, bgcolor = stochRsiColor1, text_color = color.white, text_size = currentTableTextSize) // New cell

// 5 Minutes Timeframe
[cond5Min20, color5Min20, cond5Min50, color5Min50, macdCond5, macdColor5, stochRsiCond5, stochRsiColor5] = get_timeframe_data('5')
table.cell(tbl, 2, 0, '5 Minute', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // Timeframe column to dark grey
table.cell(tbl, 2, 1, cond5Min20, bgcolor = color5Min20, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 2, 2, cond5Min50, bgcolor = color5Min50, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 2, 3, macdCond5, bgcolor = macdColor5, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 2, 4, stochRsiCond5, bgcolor = stochRsiColor5, text_color = color.white, text_size = currentTableTextSize) // New cell

// 15 Minutes Timeframe
[cond15Min20, color15Min20, cond15Min50, color15Min50, macdCond15, macdColor15, stochRsiCond15, stochRsiColor15] = get_timeframe_data('15')
table.cell(tbl, 3, 0, '15 Minute', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // Timeframe column to dark grey
table.cell(tbl, 3, 1, cond15Min20, bgcolor = color15Min20, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 3, 2, cond15Min50, bgcolor = color15Min50, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 3, 3, macdCond15, bgcolor = macdColor15, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 3, 4, stochRsiCond15, bgcolor = stochRsiColor15, text_color = color.white, text_size = currentTableTextSize) // New cell

// 1 Hour Timeframe
[cond1H20, color1H20, cond1H50, color1H50, macdCond60, macdColor60, stochRsiCond60, stochRsiColor60] = get_timeframe_data('60')
table.cell(tbl, 4, 0, '1 Hour', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // Timeframe column to dark grey
table.cell(tbl, 4, 1, cond1H20, bgcolor = color1H20, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 4, 2, cond1H50, bgcolor = color1H50, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 4, 3, macdCond60, bgcolor = macdColor60, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 4, 4, stochRsiCond60, bgcolor = stochRsiColor60, text_color = color.white, text_size = currentTableTextSize) // New cell

// 4 Hours Timeframe
[cond4H20, color4H20, cond4H50, color4H50, macdCond240, macdColor240, stochRsiCond240, stochRsiColor240] = get_timeframe_data('240')
table.cell(tbl, 5, 0, '4 Hour', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // Timeframe column to dark grey
table.cell(tbl, 5, 1, cond4H20, bgcolor = color4H20, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 5, 2, cond4H50, bgcolor = color4H50, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 5, 3, macdCond240, bgcolor = macdColor240, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 5, 4, stochRsiCond240, bgcolor = stochRsiColor240, text_color = color.white, text_size = currentTableTextSize) // New cell

// 1 Day Timeframe
[cond1D20, color1D20, cond1D50, color1D50, macdCondD, macdColorD, stochRsiCondD, stochRsiColorD] = get_timeframe_data('D')
table.cell(tbl, 6, 0, '1 Day', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // Timeframe column to dark grey
table.cell(tbl, 6, 1, cond1D20, bgcolor = color1D20, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 6, 2, cond1D50, bgcolor = color1D50, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 6, 3, macdCondD, bgcolor = macdColorD, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 6, 4, stochRsiCondD, bgcolor = stochRsiColorD, text_color = color.white, text_size = currentTableTextSize) // New cell

// 1 Week Timeframe
[cond1W20, color1W20, cond1W50, color1W50, macdCondW, macdColorW, stochRsiCondW, stochRsiColorW] = get_timeframe_data('W')
table.cell(tbl, 7, 0, '1 Week', bgcolor = color.rgb(40, 40, 40), text_color = color.white, text_size = currentTableTextSize) // Timeframe column to dark grey
table.cell(tbl, 7, 1, cond1W20, bgcolor = color1W20, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 7, 2, cond1W50, bgcolor = color1W50, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 7, 3, macdCondW, bgcolor = macdColorW, text_color = color.white, text_size = currentTableTextSize)
table.cell(tbl, 7, 4, stochRsiCondW, bgcolor = stochRsiColorW, text_color = color.white, text_size = currentTableTextSize) // New cell

// Plot the MAs for the current timeframe (using 'open' price)
src = open
len1 = input.int(20, title = 'MA Length 1', group = 'Current Timeframe MA Plots')
len2 = input.int(50, title = 'MA Length 2', group = 'Current Timeframe MA Plots')
useweeklyMA = input.bool(true, title = 'Show weekly MAs?', group = 'Current Timeframe MA Plots')
dashedLineStyle = useweeklyMA ? plot.style_circles : plot.style_line

// Daily moving averages (based on 'open' price)
ma20_week = request.security(syminfo.tickerid, 'W', ta.ema(src, len1))
ma50_week = request.security(syminfo.tickerid, 'W', ta.ema(src, len2))

// Intraday moving averages (based on 'open' price)
ma20 = ta.ema(src, len1)
ma50 = ta.ema(src, len2)

// Plot MAs
plot(ma20, color = color.rgb(94, 255, 0, 40), title = '20MA', linewidth = 2)
plot(ma50, color = #0065fc, title = '50MA', linewidth = 2)

// Plot daily MAs as dashed lines if enabled
plot(useweeklyMA ? ma20_week : na, color = #5eff0093, style = dashedLineStyle, linewidth = 1, title = 'Daily 20MA')
plot(useweeklyMA ? ma50_week : na, color = color.rgb(0, 101, 252, 43), style = dashedLineStyle, title = 'Daily 50MA')
````
