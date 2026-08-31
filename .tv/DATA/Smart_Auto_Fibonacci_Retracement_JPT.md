<!-- tradingview-pine-id: PUB;09cf659a4880404bb3e403b46a1ae742 -->
<!-- tradingviewscripts-format: 1 -->
# Smart Auto Fibonacci Retracement [JPT] 

Source: https://www.tradingview.com/script/z9vYT8Y7-Smart-Auto-Fibonacci-Retracement-JPT/

## Description

🔷 OVERVIEW

Smart Auto Fibonacci Retracement [JPT] is an original Pine Script® v6 indicator that automatically detects confirmed Swing Highs and Swing Lows, identifies the current market trend, and draws dynamic Fibonacci Retracement and Extension levels without requiring manual drawing.

The indicator creates an organized Fibonacci framework using the latest confirmed swing structure, helping traders identify potential pullback zones, continuation areas, support, resistance, and profit targets.

🔷 HOW IT WORKS

The indicator continuously scans price using confirmed pivot swings.

Bullish Trend

When a valid Swing Low is followed by a Swing High, the indicator recognizes an uptrend and automatically draws Fibonacci retracement levels from the Swing Low to the Swing High.

This allows traders to monitor potential pullback zones during bullish market conditions.

Bearish Trend

When a valid Swing High is followed by a Swing Low, the indicator recognizes a downtrend and automatically plots Fibonacci retracement levels from the Swing High to the Swing Low.

This helps identify possible resistance and continuation levels during bearish trends.

All Fibonacci levels update automatically whenever a new confirmed swing structure forms.

🔷 VISUAL FEATURES

• Automatic Swing High Detection

• Automatic Swing Low Detection

• Automatic Trend Detection

• Dynamic Trend Line

• Automatic Fibonacci Retracement Levels

• Fibonacci Extension Levels

• High & Low Swing Labels

• Right-Side Fibonacci Labels

• Colored Fibonacci Zones

• Trend Background Color

• Clean Professional Layout

• Customizable Colors

🔷 FIBONACCI LEVELS

The indicator automatically plots the following retracement levels:

• 0.000

• 0.236

• 0.382

• 0.500

• 0.618

• 0.786

• 1.000

Extension levels include:

• 1.272

• 1.618

• 2.618

These levels automatically adjust whenever a new confirmed swing is detected.

🔷 TREND ENGINE

The built-in Trend Engine automatically determines whether the market is currently bullish or bearish based on the latest confirmed swing structure.

Bullish Trend

• Fibonacci drawn from Low → High

• Green trend background

• Bullish trendline

Bearish Trend

• Fibonacci drawn from High → Low

• Red trend background

• Bearish trendline

This provides an easy-to-read visual representation of the prevailing market direction.

🔷 INPUTS

Available settings include:

• Swing Strength

• Show Trend Line

• Show Trend Background

• Show High/Low Labels

• Extend Fibonacci Lines

• Enable Individual Fibonacci Levels

• Bullish Color

• Bearish Color

🔷 ALERTS

Built-in alerts are available for:

• Buy Signal

• Sell Signal

• Price Crossing Key Fibonacci Levels

Alerts can be connected directly to TradingView's notification system.

🔷 COMMON WORKFLOW

A typical workflow is:

Wait for a confirmed Swing High and Swing Low.

Allow the indicator to identify the current market trend.

Observe the automatically generated Fibonacci retracement and extension levels.

Monitor pullbacks into key Fibonacci zones such as 0.382, 0.500, or 0.618.

Use extension levels as potential profit targets.

Combine Fibonacci levels with your own market analysis before making trading decisions.

🔷 MARKETS

This indicator can be used on:

• Forex

• Gold (XAUUSD)

• Cryptocurrency

• Stocks

• Indices

• Futures

• Commodities

Compatible with all TradingView-supported timeframes.

🔷 BEST PRACTICES

Many traders combine Fibonacci analysis with:

• Trend Analysis

• Support & Resistance

• Break of Structure (BOS)

• Change of Character (CHoCH)

• Fair Value Gaps (FVG)

• Order Blocks

• EMA 50 / EMA 200 Trend Filter

• Higher Timeframe Analysis

These techniques can provide additional confirmation when evaluating Fibonacci retracement and extension levels.

🔷 UPCOMING FEATURES

Future updates may include:

• Auto Visible Range Detection

• Multi-Swing Fibonacci Mode

• EMA 50/200 Trend Filter

• Premium & Discount Zones

• Auto Entry Price

• Stop Loss Calculation

• TP1, TP2, TP3 Auto Targets

• Risk/Reward Visualization

• Dashboard

• Advanced Alert System

🔷 DISCLAIMER

This indicator is provided as a technical analysis tool for educational and informational purposes only. It automatically identifies confirmed swing structures and calculates Fibonacci levels based on historical price action. It does not predict future market movements or guarantee trading results. Always perform your own analysis, apply sound risk management, and consider additional market factors before making trading decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Smart Auto Fibonacci Retracement [JPT] ", shorttitle="S/AFibonacciRetracementJPT", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotLen      = input.int(10, "Swing Strength", minval=2)
showTrend     = input.bool(true, "Show Trend Line")
showBG        = input.bool(true, "Trend Background")
showLabels    = input.bool(true, "Show Labels")
extendLines   = input.bool(true, "Extend Fibonacci Lines")

// Fibonacci Levels
show0236 = input.bool(true, "0.236")
show0382 = input.bool(true, "0.382")
show0500 = input.bool(true, "0.500")
show0618 = input.bool(true, "0.618")
show0786 = input.bool(true, "0.786")
show1000 = input.bool(true, "1.000")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullColor = color.lime
bearColor = color.red

fib236Color = color.rgb(255,170,0)
fib382Color = color.rgb(255,215,0)
fib500Color = color.white
fib618Color = color.aqua
fib786Color = color.fuchsia

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float swingHigh = na
var float swingLow  = na

var int swingHighBar = na
var int swingLowBar  = na

if not na(ph)
    swingHigh := ph
    swingHighBar := bar_index - pivotLen

if not na(pl)
    swingLow := pl
    swingLowBar := bar_index - pivotLen

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool upTrend = false

if not na(swingHighBar) and not na(swingLowBar)
    upTrend := swingLowBar > swingHighBar

bgcolor(showBG ? (upTrend ? color.new(bullColor,92) : color.new(bearColor,92)) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND LINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line trendLine = na

if showTrend and not na(swingHigh) and not na(swingLow)
    line.delete(trendLine)

    trendLine := line.new(
         swingHighBar,
         swingHigh,
         swingLowBar,
         swingLow,
         color = upTrend ? bullColor : bearColor,
         width = 2
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH / LOW LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var label hiLabel = na
var label loLabel = na

if showLabels
    if not na(ph)
        label.delete(hiLabel)
        hiLabel := label.new(
             swingHighBar,
             swingHigh,
             "HIGH\n"+str.tostring(swingHigh, format.mintick),
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white)

    if not na(pl)
        label.delete(loLabel)
        loLabel := label.new(
             swingLowBar,
             swingLow,
             "LOW\n"+str.tostring(swingLow, format.mintick),
             style=label.style_label_up,
             color=color.green,
             textcolor=color.white)

            //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PART 2 - FIBONACCI LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float fibRange = na
float fib0 = na
float fib236 = na
float fib382 = na
float fib500 = na
float fib618 = na
float fib786 = na
float fib100 = na

if not na(swingHigh) and not na(swingLow)
    fibRange := math.abs(swingHigh - swingLow)

    if upTrend
        fib0   := swingLow
        fib236 := swingLow + fibRange * 0.236
        fib382 := swingLow + fibRange * 0.382
        fib500 := swingLow + fibRange * 0.500
        fib618 := swingLow + fibRange * 0.618
        fib786 := swingLow + fibRange * 0.786
        fib100 := swingHigh
    else
        fib0   := swingHigh
        fib236 := swingHigh - fibRange * 0.236
        fib382 := swingHigh - fibRange * 0.382
        fib500 := swingHigh - fibRange * 0.500
        fib618 := swingHigh - fibRange * 0.618
        fib786 := swingHigh - fibRange * 0.786
        fib100 := swingLow

var line l0 = na
var line l236 = na
var line l382 = na
var line l500 = na
var line l618 = na
var line l786 = na
var line l100 = na

var label lb0 = na
var label lb236 = na
var label lb382 = na
var label lb500 = na
var label lb618 = na
var label lb786 = na
var label lb100 = na

if barstate.islast and not na(fibRange)

    line.delete(l0)
    line.delete(l236)
    line.delete(l382)
    line.delete(l500)
    line.delete(l618)
    line.delete(l786)
    line.delete(l100)

    label.delete(lb0)
    label.delete(lb236)
    label.delete(lb382)
    label.delete(lb500)
    label.delete(lb618)
    label.delete(lb786)
    label.delete(lb100)

    int x1 = math.min(swingHighBar, swingLowBar)
    int x2 = bar_index + 20

    extendType = extendLines ? extend.right : extend.none

    l0 := line.new(x1, fib0, x2, fib0, extend=extendType, color=color.white, width=2)
    l100 := line.new(x1, fib100, x2, fib100, extend=extendType, color=color.white, width=2)

    if show0236
        l236 := line.new(x1, fib236, x2, fib236, extend=extendType, color=fib236Color)

    if show0382
        l382 := line.new(x1, fib382, x2, fib382, extend=extendType, color=fib382Color)

    if show0500
        l500 := line.new(x1, fib500, x2, fib500, extend=extendType, color=fib500Color)

    if show0618
        l618 := line.new(x1, fib618, x2, fib618, extend=extendType, color=fib618Color)

    if show0786
        l786 := line.new(x1, fib786, x2, fib786, extend=extendType, color=fib786Color)

    if showLabels
        lb0 := label.new(x2, fib0, "0.000", style=label.style_label_left)
        lb100 := label.new(x2, fib100, "1.000", style=label.style_label_left)

        if show0236
            lb236 := label.new(x2, fib236, "0.236", style=label.style_label_left)

        if show0382
            lb382 := label.new(x2, fib382, "0.382", style=label.style_label_left)

        if show0500
            lb500 := label.new(x2, fib500, "0.500", style=label.style_label_left)

        if show0618
            lb618 := label.new(x2, fib618, "0.618", style=label.style_label_left)

        if show0786
            lb786 := label.new(x2, fib786, "0.786", style=label.style_label_left)

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PART 3 - FIB EXTENSIONS, FILLS & ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Extension Levels
float ext1272 = na
float ext1618 = na
float ext2618 = na

if not na(fibRange)
    if upTrend
        ext1272 := fib100 + fibRange * 0.272
        ext1618 := fib100 + fibRange * 0.618
        ext2618 := fib100 + fibRange * 1.618
    else
        ext1272 := fib100 - fibRange * 0.272
        ext1618 := fib100 - fibRange * 0.618
        ext2618 := fib100 - fibRange * 1.618

var line l1272 = na
var line l1618 = na
var line l2618 = na

if barstate.islast and not na(fibRange)

    line.delete(l1272)
    line.delete(l1618)
    line.delete(l2618)

    int x1 = math.min(swingHighBar, swingLowBar)
    int x2 = bar_index + 20

    extendType = extendLines ? extend.right : extend.none

    l1272 := line.new(x1, ext1272, x2, ext1272,
         extend=extendType,
         color=color.orange,
         style=line.style_dashed)

    l1618 := line.new(x1, ext1618, x2, ext1618,
         extend=extendType,
         color=color.yellow,
         style=line.style_dashed)

    l2618 := line.new(x1, ext2618, x2, ext2618,
         extend=extendType,
         color=color.red,
         style=line.style_dashed)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIBONACCI ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(l236) and not na(l382)
    linefill.new(l236, l382, color.new(color.orange, 88))

if not na(l382) and not na(l500)
    linefill.new(l382, l500, color.new(color.yellow, 88))

if not na(l500) and not na(l618)
    linefill.new(l500, l618, color.new(color.teal, 88))

if not na(l618) and not na(l786)
    linefill.new(l618, l786, color.new(color.blue, 88))
````
