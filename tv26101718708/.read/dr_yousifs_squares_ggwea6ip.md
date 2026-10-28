# Dr. Yousif's squares

- url: https://www.tradingview.com/script/gGwea6Ip-Dr-Yousif-s-squares/
- type: indicator
- pine_id: PUB;8e393ffc853c40938cbe33264d5eeeef
- version: 1.0

## Description

Dr. Yousif's Squares Indicator – Complete Documentation
Overview

Dr. Yousif's Squares is a multi-timeframe price visualization indicator developed in Pine Script v6 for TradingView. Instead of using traditional support and resistance lines, the indicator represents each candle as a rectangular price zone (Square) that highlights the candle's entire trading range (High → Low).

The indicator can simultaneously display the current candle, the previous candle, and the second previous candle from multiple higher timeframes on any lower timeframe chart.

Each square also contains a dotted midpoint line representing the 50% equilibrium price of that candle.

The purpose of the indicator is to help traders quickly identify:

Higher timeframe trading ranges
Institutional price zones
Candle equilibrium (50% level)
Potential support and resistance areas
Liquidity regions
Price reactions around previous candles
Main Features
1. Multi-Timeframe Analysis

The indicator supports up to five independent timeframes simultaneously.

Default configuration:

Timeframe	Description
TF1	1 Hour
TF2	4 Hours
TF3	Daily
TF4	Weekly
TF5	Monthly

Each timeframe operates independently and has:

Separate color
Individual enable/disable option
Independent square generation

This allows traders to visualize important price ranges from several higher timeframes without changing charts.

2. Candle Squares

Instead of drawing only High and Low levels, the indicator creates a rectangle covering the complete price range of a candle.

Each square includes:

Top = High
Bottom = Low
Left = Candle opening time
Right = Extended into future

Graphically:

High
 ┌──────────────────────┐
 │                      │
 │                      │
 │---------50%----------│
 │                      │
 │                      │
 └──────────────────────┘
Low

The rectangle represents the complete trading range of that candle.

3. Current Candle Display

When enabled:

Show Current Candle = ON

The indicator creates a square using:

Current Higher Timeframe Candle

Variables:

High
Low
Time

This square updates whenever a new candle begins on that timeframe.

4. Previous Candle Display

When enabled:

Show Previous Candle = ON

The indicator displays the immediately completed candle.

Internally it uses:

high[1]
low[1]
time[1]

This helps traders monitor the last completed institutional range.

5. Previous Two Candles

When enabled:

Show Previous 2 Candles

The script also displays:

high[2]
low[2]
time[2]

This provides historical reference zones for comparison with current market behavior.

6. Midpoint (Equilibrium)

Each square contains a dotted horizontal line.

The midpoint is calculated as:

Midpoint = (High + Low) / 2

Example:

High = 100

Low = 80

Midpoint = 90

This level represents the equilibrium price of that candle.

Many traders monitor this level because price often reacts around the midpoint before continuing its trend.

7. Box Extension

The parameter:

Box Width

controls how far the rectangle extends into the future.

Formula:

Right Side =
Start Time
+
(Timeframe Seconds × Extension)

Example:

1H candle

3600 seconds

Extension = 2

The box extends

2 Hours

to the right.

8. Border Thickness

Users can customize the border width.

Available values:

1
2
3
4
5

A thicker border improves visibility on busy charts.

9. Individual Timeframe Colors

Every timeframe has its own color.

Example defaults:

1H  → Blue

4H  → Green

Daily → Orange

Weekly → Purple

Monthly → Red

This makes it easy to distinguish overlapping zones.

10. Enable / Disable Individual Timeframes

Each timeframe has an independent switch.

Example:

Enable TF1

Enable TF2

Enable TF3

Enable TF4

Enable TF5

You can display only Daily zones or only Weekly zones depending on your trading style.

11. Automatic Updates

The indicator detects when a new candle forms on each higher timeframe.

Internally:

newBar = ta.change(time) != 0

Whenever a new candle begins:

The script:

Deletes previous boxes
Deletes previous midpoint lines
Creates fresh objects

This keeps the chart clean.

12. Higher Timeframe Data

The script uses:

request.security()

to retrieve data from higher timeframes.

For every timeframe it requests:

Current candle

High

Low

Time

Previous candle

High[1]

Low[1]

Time[1]

Second previous candle

High[2]

Low[2]

Time[2]

This allows accurate multi-timeframe visualization regardless of the chart timeframe.

13. Time-Based Drawing

The indicator draws using:

xloc.bar_time

instead of

bar_index

Advantages:

No 500-bar limitation
Accurate positioning across all timeframes
Boxes maintain correct alignment during zooming and scrolling
14. Legend Table

A built-in table appears in one corner of the chart.

It displays:

TF	Color
1H	■
4H	■
1D	■
1W	■
1M	■

The table position is user-selectable:

Top Right
Top Left
Bottom Right
Bottom Left
Trading Interpretation

The indicator itself does not generate buy or sell signals. Instead, it provides a visual framework for understanding how price interacts with significant higher-timeframe ranges.

Common ways traders use these zones include:

Support

If price revisits the Low of a higher-timeframe square and buyers step in, the area may act as support.

Resistance

If price reaches the High of a higher-timeframe square and selling pressure appears, the area may function as resistance.

Equilibrium

The dotted midpoint often serves as a decision area where price may:

Reverse
Consolidate
Continue the prevailing trend

Many traders monitor this level as a balance point between buyers and sellers.

Liquidity

The extremes of each square (High and Low) frequently coincide with areas where liquidity accumulates. Price may revisit these levels to trigger resting orders before reversing or continuing.

Advantages
Multi-timeframe visualization in a single chart
Clean graphical representation of candle ranges
Automatic updates on new higher-timeframe candles
Customizable colors and appearance
Configurable box width and border thickness
Optional display of current and historical candles
Built-in legend for quick reference
Time-based drawing avoids future bar limitations
Typical Use Cases

This indicator is particularly useful for:

Price Action trading
Smart Money Concepts (SMC)
Institutional order flow analysis
Support and resistance mapping
Swing trading
Intraday trading
Scalping with higher-timeframe context
Multi-timeframe confluence analysis
Summary

Dr. Yousif's Squares transforms higher-timeframe candles into persistent price zones, allowing traders to view important market structure directly on lower-timeframe charts. Each square represents the full High-to-Low range of a candle, while the dotted midpoint highlights its equilibrium level. By combining multiple timeframes, customizable visuals, and automatic updates, the indicator provides a structured way to monitor key price zones where reactions, reversals, or continuations are more likely to occur. It is best used as a contextual analysis tool alongside price action, market structure, and risk management rather than as a standalone trading system.

## Source Code

````pine
//@version=6
indicator("Dr. Yousif's squares", overlay=true, max_boxes_count=500)

// ================= INPUTS =================
extendBars  = input.int(2, "Box Width", minval=1)
borderWidth = input.int(2, "Border Thickness", minval=1, maxval=5)
showCurrent = input.bool(true, "Show Current Candle")
showPrev    = input.bool(true, "Show Previous Candle")
showPrev2   = input.bool(true, "Show Previous 2 Candles")

// table position
tablePos = input.string("top_right", "Table Position",
     options=["top_right","top_left","bottom_right","bottom_left"])

// ================= DEFAULT TIMEFRAMES =================
tf1 = input.timeframe("60",  "TF1 (1H)")
tf2 = input.timeframe("240", "TF2 (4H)")
tf3 = input.timeframe("D",   "TF3 (Daily)")
tf4 = input.timeframe("W",   "TF4 (Weekly)")
tf5 = input.timeframe("M",   "TF5 (Monthly)")

use1 = input.bool(true, "Enable TF1")
use2 = input.bool(true, "Enable TF2")
use3 = input.bool(true, "Enable TF3")
use4 = input.bool(true, "Enable TF4")
use5 = input.bool(true, "Enable TF5")

// ================= COLORS =================
col1 = input.color(color.blue,   "TF1 Color")
col2 = input.color(color.green,  "TF2 Color")
col3 = input.color(color.orange, "TF3 Color")
col4 = input.color(color.purple, "TF4 Color")
col5 = input.color(color.red,    "TF5 Color")

// ================= POSITION =================
pos =
     tablePos == "top_right" ? position.top_right :
     tablePos == "top_left" ? position.top_left :
     tablePos == "bottom_right" ? position.bottom_right :
     position.bottom_left

// ================= FUNCTION =================
f_tf(tf, enabled, col) =>
    [h,l,t]   = request.security(syminfo.tickerid, tf, [high,low,time])
    [h1,l1,t1]= request.security(syminfo.tickerid, tf, [high[1],low[1],time[1]])
    [h2,l2,t2]= request.security(syminfo.tickerid, tf, [high[2],low[2],time[2]])

    newBar = ta.change(t) != 0

    var box c  = na
    var box p  = na
    var box p2 = na

    var line cL  = na
    var line pL  = na
    var line p2L = na

    if enabled and newBar
        box.delete(c), box.delete(p), box.delete(p2)
        line.delete(cL), line.delete(pL), line.delete(p2L)

        if showCurrent
            c := box.new(t, h, t + timeframe.in_seconds(tf)*1000*extendBars, l,
                xloc=xloc.bar_time,
                bgcolor=color.new(col, 100),
                border_color=col,
                border_width=borderWidth)

            cMid = (h + l) / 2
            cL := line.new(t, cMid, t + timeframe.in_seconds(tf)*1000*extendBars, cMid,
                xloc=xloc.bar_time,
                color=col,
                style=line.style_dotted,
                width=1)

        if showPrev
            p := box.new(t1, h1, t1 + timeframe.in_seconds(tf)*1000*extendBars, l1,
                xloc=xloc.bar_time,
                bgcolor=color.new(col, 100),
                border_color=col,
                border_width=borderWidth)

            pMid = (h1 + l1) / 2
            pL := line.new(t1, pMid, t1 + timeframe.in_seconds(tf)*1000*extendBars, pMid,
                xloc=xloc.bar_time,
                color=col,
                style=line.style_dotted,
                width=1)

        if showPrev2
            p2 := box.new(t2, h2, t2 + timeframe.in_seconds(tf)*1000*extendBars, l2,
                xloc=xloc.bar_time,
                bgcolor=color.new(col, 100),
                border_color=col,
                border_width=borderWidth)

            p2Mid = (h2 + l2) / 2
            p2L := line.new(t2, p2Mid, t2 + timeframe.in_seconds(tf)*1000*extendBars, p2Mid,
                xloc=xloc.bar_time,
                color=col,
                style=line.style_dotted,
                width=1)

    [c,p,p2]

// ================= EXECUTION =================
f_tf(tf1, use1, col1)
f_tf(tf2, use2, col2)
f_tf(tf3, use3, col3)
f_tf(tf4, use4, col4)
f_tf(tf5, use5, col5)

// ================= TABLE =================
var table t = table.new(pos, 2, 6, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "TF", text_color=color.white)
    table.cell(t, 1, 0, "Color", text_color=color.white)

    table.cell(t, 0, 1, "1H", text_color=color.white)
    table.cell(t, 1, 1, "■", text_color=col1)

    table.cell(t, 0, 2, "4H", text_color=color.white)
    table.cell(t, 1, 2, "■", text_color=col2)

    table.cell(t, 0, 3, "1D", text_color=color.white)
    table.cell(t, 1, 3, "■", text_color=col3)

    table.cell(t, 0, 4, "1W", text_color=color.white)
    table.cell(t, 1, 4, "■", text_color=col4)

    table.cell(t, 0, 5, "1M", text_color=color.white)
    table.cell(t, 1, 5, "■", text_color=col5)
````
