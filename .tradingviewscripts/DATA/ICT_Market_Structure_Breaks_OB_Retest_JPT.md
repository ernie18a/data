<!-- tradingview-pine-id: PUB;0599c5647127443c9968435499652123 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Market Structure Breaks + OB Retest [JPT]

Source: https://www.tradingview.com/script/9zSE7DhS-ICT-Market-Structure-BREAKS-OB-Retest-JPT/

## Description

🔷 OVERVIEW

ICT Market Structure Blocks + OB Retest [JPT] Trade market structure with a clean, rule-based approach combining Market Structure Breaks (MSB), Order Blocks, and OB Retests — designed to help traders identify potential continuation setups without unnecessary chart clutter.

🔹 Key Features

🔹 Market Structure Break (MSB)
• Identifies confirmed swing highs and swing lows.
• Detects bullish and bearish structure breaks.
• Displays clear MSB ↑ / MSB ↓ levels directly on the chart.
• Uses confirmed pivots to reduce noisy structure changes.
🔹 Order Block Detection
• Automatically searches for the relevant opposing candle before the structure break.
• Creates bullish BU-OB and bearish BE-OB zones.
• Zones can be extended forward for potential future retests.
• Broken order blocks can automatically be removed.
🔹 OB Retest Detection
• Identifies when price returns to a previously established Order Block.
• Provides separate alert conditions for bullish and bearish OB retests.
• Useful for traders looking for confirmation after a market structure break.
🔹 Displacement Filter
• Optional ATR-based displacement confirmation.
• Helps filter weaker structure breaks and focus on stronger candles.
• Fully adjustable from the settings.

🔹 Customizable Settings

You can adjust:
• Swing Length
• OB Search Lookback
• Maximum OB Zones
• Zone Extension
• ATR Length
• Minimum Body / ATR
• Displacement Filter
• Bullish/Bearish OB colors
• Structure visibility
• Swing labels
•Automatic broken-zone deletion

🔹 Basic Trading Concept

Bullish setup:
Bullish MSB → Bullish OB → Price Returns to OB → Potential Long Area

Bearish setup:
Bearish MSB → Bearish OB → Price Returns to OB → Potential Short Area

This indicator is intended as a market-structure and price-action tool, not a guaranteed buy/sell system. Always backtest the settings for your specific market and timeframe and combine the signals with your own risk-management rules.

🔔 Alerts

Available alerts include:

Bullish MSB
Bearish MSB
Bullish OB Retest
Bearish OB Retest

Recommended starting point: try a Swing Length of 8 and adjust the OB/ATR settings according to the volatility of your market.

Disclaimer: This indicator is for educational and analytical purposes only. It does not provide guaranteed profitable signals or financial advice. Trading involves substantial risk, and past performance does not guarantee future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("ICT Market Structure Breaks + OB Retest [JPT]", "MSB_OB", overlay=true,
     max_lines_count=200, max_boxes_count=100, max_labels_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStructure = "Market Structure"
pivotLen       = input.int(8, "Swing Length", minval=2, maxval=20, group=groupStructure)
showStructure  = input.bool(true, "Show BOS / Structure", group=groupStructure)
showSwings     = input.bool(false, "Show Swing Labels", group=groupStructure)

groupOB = "Order Blocks"
showOB          = input.bool(true, "Show Order Blocks", group=groupOB)
obLookback      = input.int(12, "OB Search Lookback", minval=3, maxval=50, group=groupOB)
maxZones        = input.int(8, "Maximum Zones Per Side", minval=1, maxval=20, group=groupOB)
deleteBroken    = input.bool(true, "Delete Broken Zones", group=groupOB)
extendBars      = input.int(40, "Zone Extension", minval=5, maxval=200, group=groupOB)

groupFilter = "Breakout Filter"
useDisplace = input.bool(true, "Displacement Filter", group=groupFilter)
atrLen      = input.int(14, "ATR Length", minval=2, group=groupFilter)
atrFactor   = input.float(0.50, "Minimum Body / ATR", minval=0.0, step=0.05, group=groupFilter)

groupVisual = "Visuals"
bullColor   = input.color(color.new(color.green, 82), "Bullish OB", group=groupVisual)
bullBorder  = input.color(color.green, "Bullish Border", group=groupVisual)
bearColor   = input.color(color.new(color.red, 82), "Bearish OB", group=groupVisual)
bearBorder  = input.color(color.red, "Bearish Border", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR / DISPLACEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr = ta.atr(atrLen)

bullDisplacement = (close - open) >= atr * atrFactor
bearDisplacement = (open - close) >= atr * atrFactor

bullFilter = not useDisplace or bullDisplacement
bearFilter = not useDisplace or bearDisplacement

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONFIRMED SWINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

var float swingHigh = na
var float swingLow  = na

var int swingHighBar = na
var int swingLowBar  = na

if not na(pivotHigh)
    swingHigh := pivotHigh
    swingHighBar := bar_index - pivotLen

    if showSwings
        label.new(
             swingHighBar,
             swingHigh,
             "SH",
             style=label.style_label_down,
             color=color.new(color.red, 100),
             textcolor=color.red,
             size=size.tiny)

if not na(pivotLow)
    swingLow := pivotLow
    swingLowBar := bar_index - pivotLen

    if showSwings
        label.new(
             swingLowBar,
             swingLow,
             "SL",
             style=label.style_label_up,
             color=color.new(color.green, 100),
             textcolor=color.green,
             size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAK OF STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullBOS =
     not na(swingHigh) and
     close > swingHigh and
     close[1] <= swingHigh and
     bullFilter

bearBOS =
     not na(swingLow) and
     close < swingLow and
     close[1] >= swingLow and
     bearFilter

if bullBOS

    if showStructure
        line.new(
             swingHighBar,
             swingHigh,
             bar_index,
             swingHigh,
             color=color.green,
             width=2)

        label.new(
             bar_index,
             swingHigh,
             "MSB ↑",
             style=label.style_label_down,
             color=color.new(color.green, 85),
             textcolor=color.green,
             size=size.small)

    swingHigh := na

if bearBOS

    if showStructure
        line.new(
             swingLowBar,
             swingLow,
             bar_index,
             swingLow,
             color=color.red,
             width=2)

        label.new(
             bar_index,
             swingLow,
             "MSB ↓",
             style=label.style_label_up,
             color=color.new(color.red, 85),
             textcolor=color.red,
             size=size.small)

    swingLow := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDER BLOCK STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box[] bullOBs = array.new_box()
var box[] bearOBs = array.new_box()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BULLISH ORDER BLOCK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if bullBOS and showOB

    int obBar = na

    for i = 1 to obLookback
        if open[i] > close[i]
            obBar := i
            break

    if not na(obBar)

        float obTop = high[obBar]
        float obBottom = low[obBar]

        box newBullOB = box.new(
             left=bar_index - obBar,
             top=obTop,
             right=bar_index + extendBars,
             bottom=obBottom,
             bgcolor=bullColor,
             border_color=bullBorder,
             text="BU-OB",
             text_color=bullBorder,
             text_halign=text.align_right,
             text_size=size.tiny)

        array.push(bullOBs, newBullOB)

        if array.size(bullOBs) > maxZones
            box oldBull = array.shift(bullOBs)
            box.delete(oldBull)
            
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BEARISH ORDER BLOCK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if bearBOS and showOB

    int obBar = na

    for i = 1 to obLookback
        if open[i] < close[i]
            obBar := i
            break

    if not na(obBar)

        float obTop = high[obBar]
        float obBottom = low[obBar]

        box newBearOB = box.new(
             left=bar_index - obBar,
             top=obTop,
             right=bar_index + extendBars,
             bottom=obBottom,
             bgcolor=bearColor,
             border_color=bearBorder,
             text="BE-OB",
             text_color=bearBorder,
             text_halign=text.align_right,
             text_size=size.tiny)

        array.push(bearOBs, newBearOB)

        if array.size(bearOBs) > maxZones
            box oldBear = array.shift(bearOBs)
            box.delete(oldBear)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE BULLISH ORDER BLOCKS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool bullRetest = false

if array.size(bullOBs) > 0

    for i = array.size(bullOBs) - 1 to 0

        box b = array.get(bullOBs, i)

        float top = box.get_top(b)
        float bottom = box.get_bottom(b)

        box.set_right(b, bar_index + extendBars)

        if close < bottom

            if deleteBroken
                box.delete(b)

            array.remove(bullOBs, i)

        else if close[1] > top and low <= top and close >= bottom

            bullRetest := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE BEARISH ORDER BLOCKS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool bearRetest = false

if array.size(bearOBs) > 0

    for i = array.size(bearOBs) - 1 to 0

        box b = array.get(bearOBs, i)

        float top = box.get_top(b)
        float bottom = box.get_bottom(b)

        box.set_right(b, bar_index + extendBars)

        if close > top

            if deleteBroken
                box.delete(b)

            array.remove(bearOBs, i)

        else if close[1] < bottom and high >= bottom and close <= top

            bearRetest := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     bullBOS,
     title="Bullish BOS",
     message="Bullish Break of Structure detected.")

alertcondition(
     bearBOS,
     title="Bearish BOS",
     message="Bearish Break of Structure detected.")

alertcondition(
     bullRetest,
     title="Bullish OB Retest",
     message="Price has retested a Bullish Order Block.")

alertcondition(
     bearRetest,
     title="Bearish OB Retest",
     message="Price has retested a Bearish Order Block.")
````
