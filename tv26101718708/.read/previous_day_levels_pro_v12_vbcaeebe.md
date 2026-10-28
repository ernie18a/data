# Previous Day Levels PRO v1.2

- url: https://www.tradingview.com/script/vbcaEEBE-Previous-Day-Levels-PRO-v1-2/
- type: indicator
- pine_id: PUB;dff42d4c34ef4ac387b099391ed484f7
- version: 1.0

## Description

Crypto Sessions V1.7 is an advanced ICT-style session and liquidity indicator built for crypto traders who want clear session structure, volatility timing, and entry confirmation in one tool. It highlights the Asia, London, and New York sessions while automatically plotting key liquidity levels, volatility windows, Silver Bullet setups, Fibonacci retracement zones, and entry confirmations. 

It is designed to help you track where liquidity builds, where sweeps happen, and where high probability reversals or continuations form during active market hours.

Key Features

• Asia, London, and New York session boxes
• Asia High, Asia Low, and Asia Mid levels
• Automatic Fibonacci retracement levels
• 0.618 to 0.705 Golden Zone
• Volatility windows for London and New York
• ICT Silver Bullet windows
• Liquidity sweep detection
• BOS confirmation signals
• BUY and SELL entry labels
• Judas Swing detection
• Full colour and opacity customisation

How to Use Crypto Sessions V1.7

1. Mark the Asia Range
   Use the Asia session box and Asia High/Low levels as your primary liquidity reference.

The Asia range acts as the overnight accumulation zone. Price often sweeps one side of this range before reversing during London or New York volatility.

2. Wait for a Liquidity Sweep
   Look for price to take the Asia High or Asia Low.

Bullish setup:
• Price sweeps Asia Low
• Candle closes back above the level

Bearish setup:
• Price sweeps Asia High
• Candle closes back below the level

The indicator marks these automatically with sweep signals.

3. Confirm BOS
   After the sweep, wait for BOS confirmation.

Bullish BOS:
• Price closes above previous candle high

Bearish BOS:
• Price closes below previous candle low

This confirms market structure shift and momentum.

4. Use the Golden Zone for Entries
   The automatic Fibonacci retracement plots:
   • 50%
   • 0.618
   • 0.705

The 0.618 to 0.705 area forms the Golden Zone.

Wait for price to retrace into this zone after BOS confirmation. This gives higher probability entries with tighter risk.

5. Trade During Volatility Windows
   The best setups form during:
   • London volatility window
   • New York volatility window
   • Silver Bullet windows

Avoid taking signals during low volatility periods.

How to Use It in Conjunction with Your Previous High and Low Indicator

Your Previous High and Low indicator gives higher timeframe liquidity targets.

Combine them like this:

Bullish Example
• Daily Low gets swept
• Price enters London volatility window
• Asia Low gets swept
• Bullish Judas or BOS forms
• Enter from Golden Zone retracement
• Target Previous Day High

Bearish Example
• Daily High gets swept
• Price enters New York volatility window
• Asia High gets swept
• Bearish BOS forms
• Enter from Golden Zone retracement
• Target Previous Day Low

Best Workflow

Higher timeframe:
• Previous Day High/Low
• Weekly High/Low
• Overall bias

Intraday execution:
• Asia sweep
• BOS confirmation
• Golden Zone retracement
• Volatility window timing

Best Timeframes

• Bias: 1H to 4H
• Execution: 1M to 15M
• Best balance: 5M

Best Markets

• BTCUSD
• ETHUSD
• NASDAQ
• Gold
• GBPUSD
• EURUSD

Suggested Trading Rules

• Trade only during volatility windows
• Avoid ranging conditions
• Wait for sweep first
• Confirm BOS before entry
• Use Golden Zone retracement
• Target opposing liquidity

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © D20Trades

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © D20Trades

//@version=5
indicator("Previous Day Levels PRO v1.2", overlay=true, max_lines_count=50, max_labels_count=50)

//━━━━━━━━━━━━━━━━━━━
// COLOURS
//━━━━━━━━━━━━━━━━━━━

pdhColor = input.color(color.aqua, "Prev Day High Color")
pdlColor = input.color(color.aqua, "Prev Day Low Color")
openColor = input.color(color.aqua, "Daily Open Color")

//━━━━━━━━━━━━━━━━━━━
// LINE LENGTH SETTINGS
//━━━━━━━━━━━━━━━━━━━

// Extend LEFT
pdLeftBars = input.int(40, "PDH / PDL Extend Left", minval=0, maxval=500)
openLeftBars = input.int(10, "Daily Open Extend Left", minval=0, maxval=500)

// Extend RIGHT
pdRightBars = input.int(300, "PDH / PDL Extend Right", minval=10, maxval=2000)
openRightBars = input.int(120, "Daily Open Extend Right", minval=10, maxval=2000)

//━━━━━━━━━━━━━━━━━━━
// WIDTH SETTINGS
//━━━━━━━━━━━━━━━━━━━

pdLineWidth = input.int(2, "PDH / PDL Width", minval=1, maxval=10)
openLineWidth = input.int(2, "Daily Open Width", minval=1, maxval=10)

//━━━━━━━━━━━━━━━━━━━
// STYLE SETTINGS
//━━━━━━━━━━━━━━━━━━━

lineStyleOpt = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

lineStyle = lineStyleOpt == "Solid" ? line.style_solid :
     lineStyleOpt == "Dashed" ? line.style_dashed :
     line.style_dotted

//━━━━━━━━━━━━━━━━━━━
// LABEL SETTINGS
//━━━━━━━━━━━━━━━━━━━

showLabels = input.bool(true, "Show Labels")

textSizeOpt = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

textOffset = input.int(5, "Text Offset", minval=0, maxval=50)

textSize = textSizeOpt == "Tiny" ? size.tiny :
     textSizeOpt == "Small" ? size.small :
     textSizeOpt == "Large" ? size.large :
     textSizeOpt == "Huge" ? size.huge :
     size.normal

//━━━━━━━━━━━━━━━━━━━
// ALERT SETTINGS
//━━━━━━━━━━━━━━━━━━━

enablePDHAlerts = input.bool(true, "Enable PDH Alerts")
enablePDLAlerts = input.bool(true, "Enable PDL Alerts")
enableOpenAlerts = input.bool(true, "Enable Daily Open Alerts")

//━━━━━━━━━━━━━━━━━━━
// DAILY LEVELS
//━━━━━━━━━━━━━━━━━━━

prevHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)

prevLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

dailyOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

//━━━━━━━━━━━━━━━━━━━
// NEW DAY DETECTION
//━━━━━━━━━━━━━━━━━━━

newDay = ta.change(time("D"))

//━━━━━━━━━━━━━━━━━━━
// STORAGE
//━━━━━━━━━━━━━━━━━━━

var line highLine = na
var line lowLine = na
var line openLine = na

var label highLabel = na
var label lowLabel = na
var label openLabel = na

//━━━━━━━━━━━━━━━━━━━
// CREATE NEW LEVELS
//━━━━━━━━━━━━━━━━━━━

if newDay or barstate.isfirst

    // Delete old lines
    line.delete(highLine)
    line.delete(lowLine)
    line.delete(openLine)

    // Delete old labels
    label.delete(highLabel)
    label.delete(lowLabel)
    label.delete(openLabel)

    // Bar Positions
    pdStart = bar_index - pdLeftBars
    pdEnd = bar_index + pdRightBars

    openStart = bar_index - openLeftBars
    openEnd = bar_index + openRightBars

    // Previous Day High
    highLine := line.new(
         x1 = pdStart,
         y1 = prevHigh,
         x2 = pdEnd,
         y2 = prevHigh,
         color = pdhColor,
         width = pdLineWidth,
         style = lineStyle
     )

    // Previous Day Low
    lowLine := line.new(
         x1 = pdStart,
         y1 = prevLow,
         x2 = pdEnd,
         y2 = prevLow,
         color = pdlColor,
         width = pdLineWidth,
         style = lineStyle
     )

    // Daily Open
    openLine := line.new(
         x1 = openStart,
         y1 = dailyOpen,
         x2 = openEnd,
         y2 = dailyOpen,
         color = openColor,
         width = openLineWidth,
         style = lineStyle
     )

    // Labels
    if showLabels

        highLabel := label.new(
             x = pdEnd + textOffset,
             y = prevHigh,
             text = "Prev Day High",
             style = label.style_none,
             textcolor = pdhColor,
             size = textSize
         )

        lowLabel := label.new(
             x = pdEnd + textOffset,
             y = prevLow,
             text = "Prev Day Low",
             style = label.style_none,
             textcolor = pdlColor,
             size = textSize
         )

        openLabel := label.new(
             x = openEnd + textOffset,
             y = dailyOpen,
             text = "Daily Open",
             style = label.style_none,
             textcolor = openColor,
             size = textSize
         )

//━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━

pdhCrossUp = ta.crossover(close, prevHigh)
pdhCrossDown = ta.crossunder(close, prevHigh)

pdlCrossUp = ta.crossover(close, prevLow)
pdlCrossDown = ta.crossunder(close, prevLow)

openCrossUp = ta.crossover(close, dailyOpen)
openCrossDown = ta.crossunder(close, dailyOpen)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━

alertcondition(enablePDHAlerts and pdhCrossUp, title="PDH Break Above", message="Price broke ABOVE Previous Day High on {{ticker}}")

alertcondition(enablePDHAlerts and pdhCrossDown, title="PDH Break Below", message="Price broke BELOW Previous Day High on {{ticker}}")

alertcondition(enablePDLAlerts and pdlCrossUp, title="PDL Break Above", message="Price broke ABOVE Previous Day Low on {{ticker}}")

alertcondition(enablePDLAlerts and pdlCrossDown, title="PDL Break Below", message="Price broke BELOW Previous Day Low on {{ticker}}")

alertcondition(enableOpenAlerts and openCrossUp, title="Daily Open Break Above", message="Price broke ABOVE Daily Open on {{ticker}}")

alertcondition(enableOpenAlerts and openCrossDown, title="Daily Open Break Below", message="Price broke BELOW Daily Open on {{ticker}}")
````
