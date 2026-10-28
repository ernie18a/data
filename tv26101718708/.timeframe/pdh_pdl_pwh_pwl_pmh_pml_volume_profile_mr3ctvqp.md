# PDH PDL PWH PWL PMH PML + Volume Profile

- url: https://www.tradingview.com/script/mR3CTVQp-PDH-PDL-PWH-PWL-PMH-PML-Volume-Profile/
- type: indicator
- pine_id: PUB;1714852d7bd444a98fdcbe0e4b5afc5a
- version: 2.0

## Description

This Pine Script creates a complete multi-timeframe support and resistance system for TradingView charts.

Main Features
1. Previous Day High & Low
Draws previous day high and low lines
Marks them with:
D = Daily levels
Works as intraday support and resistance
2. Previous Week High & Low
Draws previous week high and low
Marks them with:
W = Weekly levels
Useful for swing trading and strong breakout zones
3. Previous Month High & Low
Draws previous month high and low
Marks them with:
M = Monthly levels
Major institutional support and resistance zones
4. Volume Profile Levels

The script also creates simplified volume profile levels:

POC = Point of Control
Highest traded price zone
VR = Volume Resistance
Heavy supply zone
VS = Volume Support
Heavy demand zone

These are calculated using:

Highest price
Lowest price
VWMA (Volume Weighted Moving Average)

## Source Code

````pine
//@version=5
indicator("PDH PDL PWH PWL PMH PML + Volume Profile", overlay=true,
     max_lines_count=500,
     max_labels_count=500)

//══════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════
showLevels = input.bool(true, title="Show All Levels")

vpLength   = input.int(100, title="Volume Profile Lookback")
bins       = input.int(24, title="Volume Profile Rows")

//══════════════════════════════════════════════
// PREVIOUS DAY HIGH & LOW
//══════════════════════════════════════════════
prevDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1])

prevDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1])

//══════════════════════════════════════════════
// PREVIOUS WEEK HIGH & LOW
//══════════════════════════════════════════════
prevWeekHigh = request.security(
     syminfo.tickerid,
     "W",
     high[1])

prevWeekLow = request.security(
     syminfo.tickerid,
     "W",
     low[1])

//══════════════════════════════════════════════
// PREVIOUS MONTH HIGH & LOW
//══════════════════════════════════════════════
prevMonthHigh = request.security(
     syminfo.tickerid,
     "M",
     high[1])

prevMonthLow = request.security(
     syminfo.tickerid,
     "M",
     low[1])

//══════════════════════════════════════════════
// VOLUME PROFILE
//══════════════════════════════════════════════
highestPrice = ta.highest(high, vpLength)
lowestPrice  = ta.lowest(low, vpLength)

priceRange = highestPrice - lowestPrice
rowSize    = priceRange / bins

// POC Approximation
poc = ta.vwma(close, vpLength)

// Volume Profile Support & Resistance
vpResistance = highestPrice - rowSize
vpSupport    = lowestPrice + rowSize

//══════════════════════════════════════════════
// DRAW LINES
//══════════════════════════════════════════════
var line pdhLine = na
var line pdlLine = na

var line pwhLine = na
var line pwlLine = na

var line pmhLine = na
var line pmlLine = na

var line vpResLine = na
var line vpSupLine = na
var line pocLine   = na

// Labels
var label pdhLabel = na
var label pdlLabel = na

var label pwhLabel = na
var label pwlLabel = na

var label pmhLabel = na
var label pmlLabel = na

var label vpResLabel = na
var label vpSupLabel = na

var label pocLabel = na

if barstate.islast and showLevels

    //════════ DELETE OLD OBJECTS ════════
    line.delete(pdhLine)
    line.delete(pdlLine)

    line.delete(pwhLine)
    line.delete(pwlLine)

    line.delete(pmhLine)
    line.delete(pmlLine)

    line.delete(vpResLine)
    line.delete(vpSupLine)
    line.delete(pocLine)

    label.delete(pdhLabel)
    label.delete(pdlLabel)

    label.delete(pwhLabel)
    label.delete(pwlLabel)

    label.delete(pmhLabel)
    label.delete(pmlLabel)

    label.delete(vpResLabel)
    label.delete(vpSupLabel)

    label.delete(pocLabel)

    //════════ DAY LINES ════════
    pdhLine := line.new(
         bar_index - 100,
         prevDayHigh,
         bar_index,
         prevDayHigh,
         extend=extend.right,
         color=color.red,
         width=2)

    pdlLine := line.new(
         bar_index - 100,
         prevDayLow,
         bar_index,
         prevDayLow,
         extend=extend.right,
         color=color.green,
         width=2)

    //════════ DAY LABELS ════════
    pdhLabel := label.new(
         bar_index - 100,
         prevDayHigh,
         text="DAY HIGH",
         style=label.style_label_right,
         color=color.red,
         textcolor=color.white,
         size=size.small)

    pdlLabel := label.new(
         bar_index - 100,
         prevDayLow,
         text="DAY LOW",
         style=label.style_label_right,
         color=color.green,
         textcolor=color.white,
         size=size.small)

    //════════ WEEK LINES ════════
    pwhLine := line.new(
         bar_index - 200,
         prevWeekHigh,
         bar_index,
         prevWeekHigh,
         extend=extend.right,
         color=color.orange,
         width=2)

    pwlLine := line.new(
         bar_index - 200,
         prevWeekLow,
         bar_index,
         prevWeekLow,
         extend=extend.right,
         color=color.aqua,
         width=2)

    //════════ WEEK LABELS ════════
    pwhLabel := label.new(
         bar_index - 200,
         prevWeekHigh,
         text="WEEK HIGH",
         style=label.style_label_right,
         color=color.orange,
         textcolor=color.white,
         size=size.small)

    pwlLabel := label.new(
         bar_index - 200,
         prevWeekLow,
         text="WEEK LOW",
         style=label.style_label_right,
         color=color.aqua,
         textcolor=color.white,
         size=size.small)

    //════════ MONTH LINES ════════
    pmhLine := line.new(
         bar_index - 300,
         prevMonthHigh,
         bar_index,
         prevMonthHigh,
         extend=extend.right,
         color=color.purple,
         width=3)

    pmlLine := line.new(
         bar_index - 300,
         prevMonthLow,
         bar_index,
         prevMonthLow,
         extend=extend.right,
         color=color.yellow,
         width=3)

    //════════ MONTH LABELS ════════
    pmhLabel := label.new(
         bar_index - 300,
         prevMonthHigh,
         text="MONTH HIGH",
         style=label.style_label_right,
         color=color.purple,
         textcolor=color.white,
         size=size.small)

    pmlLabel := label.new(
         bar_index - 300,
         prevMonthLow,
         text="MONTH LOW",
         style=label.style_label_right,
         color=color.yellow,
         textcolor=color.black,
         size=size.small)

    //════════ VOLUME PROFILE LINES ════════
    vpResLine := line.new(
         bar_index - vpLength,
         vpResistance,
         bar_index,
         vpResistance,
         extend=extend.right,
         color=color.maroon,
         width=2)

    vpSupLine := line.new(
         bar_index - vpLength,
         vpSupport,
         bar_index,
         vpSupport,
         extend=extend.right,
         color=color.lime,
         width=2)

    pocLine := line.new(
         bar_index - vpLength,
         poc,
         bar_index,
         poc,
         extend=extend.right,
         color=color.blue,
         width=3)

    //════════ VOLUME PROFILE LABELS ════════
    vpResLabel := label.new(
         bar_index - vpLength,
         vpResistance,
         text="VP RESISTANCE",
         style=label.style_label_right,
         color=color.maroon,
         textcolor=color.white,
         size=size.small)

    vpSupLabel := label.new(
         bar_index - vpLength,
         vpSupport,
         text="VP SUPPORT",
         style=label.style_label_right,
         color=color.lime,
         textcolor=color.black,
         size=size.small)

    pocLabel := label.new(
         bar_index - vpLength,
         poc,
         text="POC",
         style=label.style_label_right,
         color=color.blue,
         textcolor=color.white,
         size=size.small)

//══════════════════════════════════════════════
// ALERT CONDITIONS
//══════════════════════════════════════════════

// Volume Profile Breakouts
vpResBreakout = ta.crossover(close, vpResistance)
vpSupBreakdown = ta.crossunder(close, vpSupport)

//══════════════════════════════════════════════
// ALERT CONDITIONS
//══════════════════════════════════════════════
alertcondition(
     vpResBreakout,
     title="VP Resistance Breakout",
     message="Price crossed above Volume Profile Resistance")

alertcondition(
     vpSupBreakdown,
     title="VP Support Breakdown",
     message="Price crossed below Volume Profile Support")
````
