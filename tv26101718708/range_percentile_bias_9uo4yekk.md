# Range Percentile Bias

- url: https://www.tradingview.com/script/9uO4yeKK-Range-Percentile-Bias/
- type: indicator
- pine_id: PUB;fd66b8ac577f426d951d98ec13d7540b
- version: 1.0

## Description

Range Percentile Bias with Transition Highlights

Range Percentile Bias with Transition Highlights is designed to evaluate where current price sits within a historical price range and translate that positioning into an easy-to-read directional bias framework.

Rather than using traditional trend or momentum calculations, this indicator analyzes the current price location relative to the highest high and lowest low over a user-defined lookback period. The goal is to provide a quick assessment of whether price is trading near the lower, middle, or upper portions of its recent range and classify that positioning into market bias categories. Built from the functionality and logic contained within your indicator.

Features

• Configurable lookback range period
• Percentile-based bias classification
• Adjustable bullish and bearish threshold levels
• Neutral zone customization
• Transition highlight system
• Lookback high and low visual references
• Dynamic summary table
• Table position customization
• Table size customization
• Custom color settings
• Transition alerts

Bias States

🟢 Very Bullish
Price is positioned near the upper extreme of the recent range.

🟢 Bullish
Price is trading within stronger bullish territory.

🟢 Slightly Bullish
Price shows moderate bullish positioning.

⚪ Neutral
Price remains within the defined balanced range.

🔴 Slightly Bearish
Price begins showing weaker relative positioning.

🔴 Bearish
Price moves toward stronger bearish territory.

🔴 Very Bearish
Price is positioned near the lower extreme of the recent range.

Transition Highlights

The indicator can visually highlight changes between larger market states:

🟨 Bullish → Neutral
🟩 Neutral → Bullish
🟧 Bearish → Neutral
🟥 Neutral → Bearish
🟪 Bullish → Bearish
🟦 Bearish → Bullish

These transitions are intended to make shifts in market behavior easier to identify without constantly monitoring percentile values.

Summary Table Includes

• Current Bias
• Current Range Percentile

Potential Use Cases

• Identify relative market positioning
• Determine bullish or bearish context
• Monitor changing market conditions
• Filter trade setups
• Identify transition periods
• Add confluence to existing systems
• Study range behavior over time

Settings Guide

High/Low Lookback Period
Controls how many historical bars are used to define the current range.

Current Price Source
Determines which price value is used for calculations.

Bias Percentile Levels
Controls where bullish, bearish, and neutral zones begin and end.

Neutral Zone
Defines the balanced area between bullish and bearish conditions.

Transition Highlights
Displays visual highlights when larger market state changes occur.

Table Position / Text Size
Adjusts dashboard placement and readability.

Alerts Included

• Very Bullish Bias
• Bullish Bias
• Slightly Bullish Bias
• Neutral Bias
• Slightly Bearish Bias
• Bearish Bias
• Very Bearish Bias

• Bullish → Neutral Transition
• Neutral → Bullish Transition
• Bearish → Neutral Transition
• Neutral → Bearish Transition
• Bullish → Bearish Transition
• Bearish → Bullish Transition

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Range Percentile Bias with Transition Highlights", overlay=true, precision=2)

//====================================================
// Inputs
//====================================================
grpCore = "Core"
lookbackBars = input.int(100, "High/Low Lookback Period", minval=2, group=grpCore)
calcSource = input.source(close, "Current Price Source", group=grpCore)

grpLevels = "Bias Percentile Levels"
veryBearMax = input.float(10.0, "Very Bearish Below %", minval=0, maxval=100, step=0.5, group=grpLevels)
bearMax     = input.float(25.0, "Bearish Below %", minval=0, maxval=100, step=0.5, group=grpLevels)
slBearMax   = input.float(40.0, "Slightly Bearish Below %", minval=0, maxval=100, step=0.5, group=grpLevels)

neutralLow  = input.float(40.0, "Neutral Zone Low %", minval=0, maxval=100, step=0.5, group=grpLevels)
neutralHigh = input.float(60.0, "Neutral Zone High %", minval=0, maxval=100, step=0.5, group=grpLevels)

slBullMin   = input.float(60.0, "Slightly Bullish Above %", minval=0, maxval=100, step=0.5, group=grpLevels)
bullMin     = input.float(75.0, "Bullish Above %", minval=0, maxval=100, step=0.5, group=grpLevels)
veryBullMin = input.float(90.0, "Very Bullish Above %", minval=0, maxval=100, step=0.5, group=grpLevels)

grpTable = "Table"
showTable = input.bool(true, "Show Table", group=grpTable)
tblPosIn = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpTable)
tblSizeIn = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpTable)

grpTransition = "Transition Highlights"
showTransitionHighlights = input.bool(true, "Show Transition Highlights", group=grpTransition)
bullToNeutralColor = input.color(color.new(color.yellow, 75), "Bullish To Neutral Highlight", group=grpTransition)
neutralToBullColor = input.color(color.new(color.lime, 75), "Neutral To Bullish Highlight", group=grpTransition)
bearToNeutralColor = input.color(color.new(color.orange, 75), "Bearish To Neutral Highlight", group=grpTransition)
neutralToBearColor = input.color(color.new(color.red, 75), "Neutral To Bearish Highlight", group=grpTransition)
bullToBearColor = input.color(color.new(color.fuchsia, 75), "Bullish Direct To Bearish Highlight", group=grpTransition)
bearToBullColor = input.color(color.new(color.aqua, 75), "Bearish Direct To Bullish Highlight", group=grpTransition)

grpColors = "Table Colors"
headerBg = input.color(color.black, "Header Background", group=grpColors)
headerTxt = input.color(color.white, "Header Text", group=grpColors)

veryBullBg = input.color(color.rgb(0, 120, 0), "Very Bullish Background", group=grpColors)
bullBg     = input.color(color.rgb(0, 170, 0), "Bullish Background", group=grpColors)
slBullBg   = input.color(color.rgb(80, 200, 80), "Slightly Bullish Background", group=grpColors)

neutralBg  = input.color(color.rgb(120, 120, 120), "Neutral Background", group=grpColors)

slBearBg   = input.color(color.rgb(220, 100, 100), "Slightly Bearish Background", group=grpColors)
bearBg     = input.color(color.rgb(200, 0, 0), "Bearish Background", group=grpColors)
veryBearBg = input.color(color.rgb(120, 0, 0), "Very Bearish Background", group=grpColors)

valueTxt = input.color(color.white, "Value Text", group=grpColors)

//====================================================
// Helpers
//====================================================
tblPos =
     tblPosIn == "Top Left" ? position.top_left :
     tblPosIn == "Top Center" ? position.top_center :
     tblPosIn == "Top Right" ? position.top_right :
     tblPosIn == "Middle Left" ? position.middle_left :
     tblPosIn == "Middle Center" ? position.middle_center :
     tblPosIn == "Middle Right" ? position.middle_right :
     tblPosIn == "Bottom Left" ? position.bottom_left :
     tblPosIn == "Bottom Center" ? position.bottom_center :
     position.bottom_right

tblSize =
     tblSizeIn == "Tiny" ? size.tiny :
     tblSizeIn == "Small" ? size.small :
     tblSizeIn == "Normal" ? size.normal :
     size.large

//====================================================
// Range Percentile Calculation
//====================================================
rangeLow = ta.lowest(low, lookbackBars)
rangeHigh = ta.highest(high, lookbackBars)
rangeSize = rangeHigh - rangeLow

rangePercentile = rangeSize != 0 ? ((calcSource - rangeLow) / rangeSize) * 100 : 50
rangePercentileClamped = math.max(0, math.min(100, rangePercentile))

//====================================================
// Bias Logic
//====================================================
bias =
     rangePercentileClamped <= veryBearMax ? "Very Bearish" :
     rangePercentileClamped <= bearMax ? "Bearish" :
     rangePercentileClamped <= slBearMax ? "Slightly Bearish" :
     rangePercentileClamped >= veryBullMin ? "Very Bullish" :
     rangePercentileClamped >= bullMin ? "Bullish" :
     rangePercentileClamped >= slBullMin ? "Slightly Bullish" :
     rangePercentileClamped >= neutralLow and rangePercentileClamped <= neutralHigh ? "Neutral" :
     "Neutral"

biasColor =
     bias == "Very Bullish" ? veryBullBg :
     bias == "Bullish" ? bullBg :
     bias == "Slightly Bullish" ? slBullBg :
     bias == "Very Bearish" ? veryBearBg :
     bias == "Bearish" ? bearBg :
     bias == "Slightly Bearish" ? slBearBg :
     neutralBg

//====================================================
// Macro State Logic
//  1  = Any Bullishness
//  0  = Neutral
// -1  = Any Bearishness
//====================================================
macroState =
     bias == "Very Bullish" or bias == "Bullish" or bias == "Slightly Bullish" ? 1 :
     bias == "Very Bearish" or bias == "Bearish" or bias == "Slightly Bearish" ? -1 :
     0

prevMacroState = nz(macroState[1], macroState)

bullToNeutral = prevMacroState == 1 and macroState == 0
neutralToBull = prevMacroState == 0 and macroState == 1

bearToNeutral = prevMacroState == -1 and macroState == 0
neutralToBear = prevMacroState == 0 and macroState == -1

bullToBear = prevMacroState == 1 and macroState == -1
bearToBull = prevMacroState == -1 and macroState == 1

transitionColor =
     bullToNeutral ? bullToNeutralColor :
     neutralToBull ? neutralToBullColor :
     bearToNeutral ? bearToNeutralColor :
     neutralToBear ? neutralToBearColor :
     bullToBear ? bullToBearColor :
     bearToBull ? bearToBullColor :
     na

bgcolor(showTransitionHighlights ? transitionColor : na, title="Bias Transition Highlight")

//====================================================
// Optional Visual Reference
//====================================================
plot(rangeHigh, "Lookback High", color=color.new(color.green, 70))
plot(rangeLow, "Lookback Low", color=color.new(color.red, 70))

//====================================================
// Table
//====================================================
var table t = table.new(tblPos, 2, 2)

if barstate.islast
    if showTable
        table.cell(t, 0, 0, "Bias", text_color=headerTxt, bgcolor=headerBg, text_size=tblSize)
        table.cell(t, 1, 0, bias, text_color=valueTxt, bgcolor=biasColor, text_size=tblSize)

        table.cell(t, 0, 1, "Percentile of Range", text_color=headerTxt, bgcolor=headerBg, text_size=tblSize)
        table.cell(t, 1, 1, str.tostring(rangePercentileClamped, "#.00") + "%", text_color=valueTxt, bgcolor=biasColor, text_size=tblSize)
    else
        table.clear(t, 0, 0, 1, 1)

//====================================================
// Alerts
//====================================================
alertcondition(bias == "Very Bullish", title="Very Bullish Bias", message="Range Percentile Bias is Very Bullish.")
alertcondition(bias == "Bullish", title="Bullish Bias", message="Range Percentile Bias is Bullish.")
alertcondition(bias == "Slightly Bullish", title="Slightly Bullish Bias", message="Range Percentile Bias is Slightly Bullish.")
alertcondition(bias == "Neutral", title="Neutral Bias", message="Range Percentile Bias is Neutral.")
alertcondition(bias == "Slightly Bearish", title="Slightly Bearish Bias", message="Range Percentile Bias is Slightly Bearish.")
alertcondition(bias == "Bearish", title="Bearish Bias", message="Range Percentile Bias is Bearish.")
alertcondition(bias == "Very Bearish", title="Very Bearish Bias", message="Range Percentile Bias is Very Bearish.")

alertcondition(bullToNeutral, title="Bullish To Neutral Transition", message="Range Percentile Bias transitioned from Bullishness to Neutral.")
alertcondition(neutralToBull, title="Neutral To Bullish Transition", message="Range Percentile Bias transitioned from Neutral to Bullishness.")
alertcondition(bearToNeutral, title="Bearish To Neutral Transition", message="Range Percentile Bias transitioned from Bearishness to Neutral.")
alertcondition(neutralToBear, title="Neutral To Bearish Transition", message="Range Percentile Bias transitioned from Neutral to Bearishness.")
alertcondition(bullToBear, title="Bullish To Bearish Transition", message="Range Percentile Bias transitioned directly from Bullishness to Bearishness.")
alertcondition(bearToBull, title="Bearish To Bullish Transition", message="Range Percentile Bias transitioned directly from Bearishness to Bullishness.")
````
