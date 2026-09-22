<!-- tradingview-pine-id: PUB;523258f364b9490aad8d9d5590660cbd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep Detector [ICT] | ReubenMiles

Source: https://www.tradingview.com/script/VJPjULd2-Liquidity-Sweep-Detector-ICT-ReubenMiles/

## Description

LIQUIDITY SWEEP DETECTOR [ICT]

Understanding liquidity is one of the most important parts of Smart Money Concepts and ICT-style market analysis.

This indicator is designed to help traders visually identify potential Buy-Side Liquidity (BSL) and Sell-Side Liquidity (SSL) sweeps directly on the chart.

BUY-SIDE LIQUIDITY — BSL
Buy-side liquidity generally sits above previous swing highs. When price trades above a previous high and then rejects back below that level, it can indicate a potential bearish liquidity sweep.

SELL-SIDE LIQUIDITY — SSL
Sell-side liquidity generally sits below previous swing lows. When price trades below a previous low and then closes back above it, it can indicate a potential bullish liquidity sweep.

HOW THE INDICATOR WORKS

• Identifies important swing highs and swing lows
• Marks potential BSL and SSL levels
• Detects price sweeps through those liquidity levels
• Highlights bullish and bearish liquidity sweeps
• Displays clear chart labels and signal markers
• Includes customizable liquidity levels
• Provides alerts for detected sweeps
• Works across different markets and timeframes

BULLISH SETUP

SSL → Liquidity Sweep → Rejection → Potential Bullish Move

BEARISH SETUP

BSL → Liquidity Sweep → Rejection → Potential Bearish Move

IMPORTANT

A liquidity sweep is not automatically a buy or sell signal.

For stronger confirmation, traders can combine the sweep with:

• BOS / CHOCH
• Fair Value Gap (FVG)
• Order Blocks
• Market Structure
• Displacement
• Premium & Discount
• Higher-timeframe bias

THE GOAL

The purpose of this indicator is to make liquidity behavior easier to visualize and help traders study how price interacts with previous highs and lows.

Use it as a market-analysis and educational tool, not as a guaranteed signal generator.

STUDY THE LIQUIDITY → UNDERSTAND THE STRUCTURE → WAIT FOR CONFIRMATION → EXECUTE WITH DISCIPLINE.

— ReubenMiles Trade FX Pro

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ReubenMiles

//@version=6
indicator("Liquidity Sweep Detector [ICT] | ReubenMiles", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStructure = "Liquidity Settings"
swingLength = input.int(5, "Swing Length", minval=1, group=groupStructure)
sweepMode = input.string("Wick + Close Back", "Sweep Confirmation",
     options=["Wick + Close Back", "Wick Only"], group=groupStructure)

groupDisplay = "Display"
showLiquidity = input.bool(true, "Show Liquidity Levels", group=groupDisplay)
showLabels = input.bool(true, "Show Sweep Labels", group=groupDisplay)
showSwingLabels = input.bool(false, "Show Swing Labels", group=groupDisplay)
extendLevels = input.bool(true, "Extend Liquidity Levels", group=groupDisplay)

groupColors = "Colors"
bslColor = input.color(color.red, "Buy-Side Liquidity", group=groupColors)
sslColor = input.color(color.green, "Sell-Side Liquidity", group=groupColors)
bullColor = input.color(color.lime, "Bullish Sweep", group=groupColors)
bearColor = input.color(color.red, "Bearish Sweep", group=groupColors)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow  = ta.pivotlow(low, swingLength, swingLength)

// Store latest liquidity levels
var float buySideLiquidity = na
var float sellSideLiquidity = na

var int buySideBar = na
var int sellSideBar = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIQUIDITY LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh)
    buySideLiquidity := pivotHigh
    buySideBar := bar_index - swingLength

if not na(pivotLow)
    sellSideLiquidity := pivotLow
    sellSideBar := bar_index - swingLength

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW LIQUIDITY LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line bslLine = na
var line sslLine = na

if not na(pivotHigh) and showLiquidity
    if not na(bslLine)
        line.delete(bslLine)

    bslLine := line.new(
         x1=buySideBar,
         y1=buySideLiquidity,
         x2=bar_index,
         y2=buySideLiquidity,
         color=bslColor,
         width=1,
         style=line.style_dashed,
         extend=extendLevels ? extend.right : extend.none)

if not na(pivotLow) and showLiquidity
    if not na(sslLine)
        line.delete(sslLine)

    sslLine := line.new(
         x1=sellSideBar,
         y1=sellSideLiquidity,
         x2=bar_index,
         y2=sellSideLiquidity,
         color=sslColor,
         width=1,
         style=line.style_dashed,
         extend=extendLevels ? extend.right : extend.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh) and showSwingLabels
    label.new(
         bar_index - swingLength,
         pivotHigh,
         "BSL",
         style=label.style_label_down,
         color=bslColor,
         textcolor=color.white,
         size=size.tiny)

if not na(pivotLow) and showSwingLabels
    label.new(
         bar_index - swingLength,
         pivotLow,
         "SSL",
         style=label.style_label_up,
         color=sslColor,
         textcolor=color.white,
         size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIQUIDITY SWEEPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bearish sweep:
// Price trades above BSL and closes back below it.

bearishSweep = not na(buySideLiquidity) and
     high > buySideLiquidity and
     (sweepMode == "Wick Only" or close < buySideLiquidity)

// Bullish sweep:
// Price trades below SSL and closes back above it.

bullishSweep = not na(sellSideLiquidity) and
     low < sellSideLiquidity and
     (sweepMode == "Wick Only" or close > sellSideLiquidity)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVENT REPEATED SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int lastSweptBSLBar = na
var int lastSweptSSLBar = na

newBearishSweep = bearishSweep and buySideBar != lastSweptBSLBar
newBullishSweep = bullishSweep and sellSideBar != lastSweptSSLBar

if newBearishSweep
    lastSweptBSLBar := buySideBar

if newBullishSweep
    lastSweptSSLBar := sellSideBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWEEP LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newBearishSweep and showLabels
    label.new(
         bar_index,
         high,
         "BEARISH\nLIQUIDITY SWEEP",
         style=label.style_label_down,
         color=bearColor,
         textcolor=color.white,
         size=size.small)

if newBullishSweep and showLabels
    label.new(
         bar_index,
         low,
         "BULLISH\nLIQUIDITY SWEEP",
         style=label.style_label_up,
         color=bullColor,
         textcolor=color.black,
         size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     newBullishSweep,
     title="Bullish Liquidity Sweep",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullColor,
     size=size.small,
     text="SSL")

plotshape(
     newBearishSweep,
     title="Bearish Liquidity Sweep",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearColor,
     size=size.small,
     text="BSL")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     newBullishSweep,
     title="Bullish Liquidity Sweep",
     message="Bullish Sell-Side Liquidity Sweep detected on {{ticker}} {{interval}}")

alertcondition(
     newBearishSweep,
     title="Bearish Liquidity Sweep",
     message="Bearish Buy-Side Liquidity Sweep detected on {{ticker}} {{interval}}")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BAR COLORING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barcolor(
     newBullishSweep ? bullColor :
     newBearishSweep ? bearColor :
     na)
````
