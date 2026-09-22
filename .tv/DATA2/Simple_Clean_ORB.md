<!-- tradingview-pine-id: PUB;bd0e3dc9fc8a4952a9d6df9853d2df1e -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Simple & Clean ORB

Source: https://www.tradingview.com/script/YvgQkfJA-Simple-Clean-ORB/

## Description

Simple & Clean ORB is a lightweight Opening Range Breakout indicator designed for traders who want the core ORB levels without unnecessary clutter.

The indicator marks the Opening Range High, Opening Range Low, and optional Midpoint, then extends those levels forward so you can clearly see when price breaks out, rejects, retests, or trades back through the opening range.

The goal is simple: give you a clean price-action framework and let the chart do the talking.

What Is an Opening Range?

The Opening Range is the high and low created during a selected period of time after a session begins.

For example, if you use:

Start Time: 8:30 AM
Range Length: 30 Minutes

The indicator records the highest high and lowest low between 8:30 AM and 9:00 AM.

Once the range is complete, those levels become important reference points for the rest of the trading session.

Traders commonly watch these levels for:

[*]Breakouts
[*]Breakout retests
[*]Rejections
[*]Failed breakouts
[*]Support and resistance
[*]Trend continuation
[*]Range rotation
[*]Market structure confirmation

Why I Created Simple & Clean ORB

There are many Opening Range indicators available, but some include signals, targets, dashboards, colors, alerts, and other features that can make a chart feel crowded.

Simple & Clean ORB was built around one idea:

Show the important ORB levels clearly and let the trader interpret the price action.

Instead of telling you when to buy or sell, the indicator gives you the structure.

You decide how price is behaving around that structure.

Main Features

Custom Opening Range Time

Choose when your Opening Range begins and how long the range lasts.

Available range lengths include:

[*]2 Minutes
[*]3 Minutes
[*]5 Minutes
[*]8 Minutes
[*]10 Minutes
[*]15 Minutes
[*]30 Minutes
[*]45 Minutes
[*]1 Hour
[*]2 Hours
[*]3 Hours
[*]4 Hours
[*]8 Hours

You can also define your own custom opening-range session.

This allows the indicator to be used with different markets and trading styles.

Custom Time Zones

The Opening Range can be calculated using your preferred time zone.

This is especially useful when trading markets whose opening times may be different from your local time.

The indicator also supports major U.S. market time zones and UTC offsets.

For U.S. index futures, traders may find America/Chicago convenient because it automatically adjusts for daylight-saving time.

Fully Customizable ORB High

The Opening Range High can be customized independently.

You can change:

[*]Color
[*]Line thickness
[*]Solid line
[*]Dashed line
[*]Dotted line

Fully Customizable ORB Low

The Opening Range Low has its own independent settings.

You can change:

[*]Color
[*]Line thickness
[*]Solid line
[*]Dashed line
[*]Dotted line

This allows the upper and lower boundaries to be visually different if desired.

Optional ORB Midpoint

The indicator can also display the 50% midpoint of the Opening Range.

The midpoint often acts as an important intraday reference level.

Price moving above or below the midpoint can help traders understand which side of the range currently has greater control.

The midpoint can be:

[*]Turned on or off
[*]Given its own color
[*]Given its own thickness
[*]Displayed as solid, dashed, or dotted

Historical Opening Ranges

You can choose whether previous Opening Ranges remain visible.

With historical data enabled, each ORB remains on the chart until the next Opening Range begins.

This can be useful when studying how price interacts with previous ranges.

If you prefer an extremely clean chart, historical ranges can be disabled.

How to Trade With the ORB

The ORB should not necessarily be treated as an automatic breakout signal.

The range is better thought of as a market structure framework.

Once the range is established, watch how price behaves around the High, Low, and Midpoint.

Bullish Breakout

A bullish scenario may develop when price:

[*]Breaks above the ORB High
[*]Holds above the range
[*]Shows increased momentum
[*]Retests the ORB High successfully
[*]Continues forming higher highs and higher lows

The ORB High may then transition from resistance into support.

Bearish Breakout

A bearish scenario may develop when price:

[*]Breaks below the ORB Low
[*]Holds below the range
[*]Shows increasing downside momentum
[*]Retests the ORB Low and rejects
[*]Continues forming lower highs and lower lows

The ORB Low may then transition from support into resistance.

Failed Breakout

Some of the most useful ORB information comes from breakouts that fail.

For example:

Price breaks above the ORB High but quickly returns inside the range.

This can signal that buyers were unable to maintain control.

The same concept applies to failed breakdowns below the ORB Low.

These situations can help reveal:

[*]Rejection
[*]Trapped traders
[*]Weak momentum
[*]Liquidity sweeps
[*]False breakouts

The Midpoint

The ORB midpoint can also provide useful market information.

If price consistently holds above the midpoint, the upper portion of the range may have greater control.

If price remains below the midpoint, the lower portion of the range may be dominant.

Repeated movement through the midpoint can also suggest that the market is rotating rather than trending.

Example Setup for U.S. Index Futures

A commonly used setup for U.S. index futures is:

Start Time: 8:30 AM Central
Opening Range: 30 Minutes
Time Zone: America/Chicago

This creates an Opening Range from:

8:30 AM – 9:00 AM Central Time

Traders can then monitor the ORB High, Low, and Midpoint throughout the remainder of the session.

Markets

Although ORB concepts are commonly associated with futures and stocks, the indicator can be used on any market where a meaningful session or time period can be defined.

Examples include:

[*]Futures
[*]Stocks
[*]Forex
[*]Indices
[*]Cryptocurrency

The appropriate Opening Range will depend on the market being traded.

The Philosophy Behind Simple & Clean ORB

The purpose of this indicator is not to predict the market.

It is to create a clearly defined area where traders can observe the battle between buyers and sellers.

Once the Opening Range is established, the market usually does one of three things:

Break above it.

Break below it.

Remain trapped inside it.

That simple framework can provide a surprisingly powerful way to organize price action.

Simple & Clean ORB keeps that framework visible without filling the chart with unnecessary information.

Sometimes the best trading tool isn't the one that adds more.

It's the one that makes the important levels easier to see.

---

## Source Code

````pine
//@version=6
indicator("Simple & Clean ORB", overlay = true, max_lines_count = 500, max_boxes_count = 500)

//──────────────────────────────────────────────────────────────────────────────
// RANGE SETTINGS
//──────────────────────────────────────────────────────────────────────────────
groupRange = "Opening Range"

rangeMode = input.string(
     "Duration from Start",
     "Range Mode",
     options = ["Duration from Start", "Custom Range"],
     group = groupRange)

startHour = input.int(
     8,
     "Start Hour",
     minval = 0,
     maxval = 23,
     group = groupRange,
     inline = "START")

startMinute = input.int(
     30,
     "Start Minute",
     minval = 0,
     maxval = 59,
     group = groupRange,
     inline = "START")

durationMinutes = input.int(
     30,
     "Time Period",
     options = [2, 3, 5, 8, 10, 15, 30, 45, 60, 120, 180, 240, 480],
     group = groupRange)

customRange = input.session(
     "0830-0900",
     "Custom Range",
     group = groupRange)

timezoneInput = input.string(
     "America/Chicago",
     "Time Zone",
     options = [
         "Exchange",
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "UTC-10",
         "UTC-8",
         "UTC-7",
         "UTC-6",
         "UTC-5",
         "UTC-4",
         "UTC-3",
         "UTC+0",
         "UTC+1",
         "UTC+2",
         "UTC+3",
         "UTC+03:30",
         "UTC+4",
         "UTC+5",
         "UTC+05:30",
         "UTC+6",
         "UTC+7",
         "UTC+8",
         "UTC+9",
         "UTC+10",
         "UTC+11",
         "UTC+12"
     ],
     group = groupRange)

tz = timezoneInput == "Exchange" ? syminfo.timezone : timezoneInput

showHistorical = input.bool(
     true,
     "Show Historical Data",
     group = groupRange)

//──────────────────────────────────────────────────────────────────────────────
// HIGH LINE SETTINGS
//──────────────────────────────────────────────────────────────────────────────
groupHigh = "ORB High"

highColor = input.color(
     color.white,
     "Color",
     group = groupHigh,
     inline = "HIGH")

highWidth = input.int(
     2,
     "Thickness",
     minval = 1,
     maxval = 5,
     group = groupHigh,
     inline = "HIGH")

highStyleInput = input.string(
     "Solid",
     "Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupHigh)

//──────────────────────────────────────────────────────────────────────────────
// MID LINE SETTINGS
//──────────────────────────────────────────────────────────────────────────────
groupMid = "ORB Midpoint"

showMid = input.bool(
     true,
     "Show Midpoint",
     group = groupMid)

midColor = input.color(
     color.gray,
     "Color",
     group = groupMid,
     inline = "MID")

midWidth = input.int(
     1,
     "Thickness",
     minval = 1,
     maxval = 5,
     group = groupMid,
     inline = "MID")

midStyleInput = input.string(
     "Dashed",
     "Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupMid)

//──────────────────────────────────────────────────────────────────────────────
// LOW LINE SETTINGS
//──────────────────────────────────────────────────────────────────────────────
groupLow = "ORB Low"

lowColor = input.color(
     color.white,
     "Color",
     group = groupLow,
     inline = "LOW")

lowWidth = input.int(
     2,
     "Thickness",
     minval = 1,
     maxval = 5,
     group = groupLow,
     inline = "LOW")

lowStyleInput = input.string(
     "Solid",
     "Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupLow)

//──────────────────────────────────────────────────────────────────────────────
// ORB RANGE BOX
//──────────────────────────────────────────────────────────────────────────────
groupBox = "ORB Range Box"

showOrbBox = input.bool(
     true,
     "Show ORB Box",
     group = groupBox)

boxColor = input.color(
     color.gray,
     "Box Color",
     group = groupBox)

boxTransparency = input.int(
     85,
     "Box Transparency",
     minval = 0,
     maxval = 100,
     tooltip = "0 = fully solid, 100 = fully transparent",
     group = groupBox)

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
getLineStyle(styleInput) =>
    styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted :
     line.style_solid

highLineStyle = getLineStyle(highStyleInput)
midLineStyle  = getLineStyle(midStyleInput)
lowLineStyle  = getLineStyle(lowStyleInput)

//──────────────────────────────────────────────────────────────────────────────
// RANGE DETECTION
//──────────────────────────────────────────────────────────────────────────────

// Duration mode: build today's opening-range timestamps in the selected timezone.
barYear  = year(time, tz)
barMonth = month(time, tz)
barDay   = dayofmonth(time, tz)

rangeStart = timestamp(tz, barYear, barMonth, barDay, startHour, startMinute, 0)
rangeEnd   = rangeStart + durationMinutes * 60 * 1000

inDurationRange = time >= rangeStart and time < rangeEnd

// Custom mode: TradingView session picker determines start and end.
inCustomRange = not na(time(timeframe.period, customRange, tz))

inRange = rangeMode == "Duration from Start" ? inDurationRange : inCustomRange
newRange = inRange and not inRange[1]


//──────────────────────────────────────────────────────────────────────────────
// ORB CALCULATION + DRAWING
//──────────────────────────────────────────────────────────────────────────────
var float orbHigh = na
var float orbLow = na

var line currentHighLine = na
var line currentMidLine = na
var line currentLowLine = na
var box currentOrbBox = na

if newRange
    // Finish or remove the previous range.
    if not na(currentHighLine)
        if showHistorical
            line.set_extend(currentHighLine, extend.none)
            line.set_x2(currentHighLine, bar_index - 1)
        else
            line.delete(currentHighLine)

    if not na(currentMidLine)
        if showHistorical
            line.set_extend(currentMidLine, extend.none)
            line.set_x2(currentMidLine, bar_index - 1)
        else
            line.delete(currentMidLine)

    if not na(currentLowLine)
        if showHistorical
            line.set_extend(currentLowLine, extend.none)
            line.set_x2(currentLowLine, bar_index - 1)
        else
            line.delete(currentLowLine)

    if not na(currentOrbBox)
        if not showHistorical
            box.delete(currentOrbBox)

    // Reset the new opening range.
    orbHigh := high
    orbLow := low
    orbMid = (orbHigh + orbLow) / 2.0

    currentHighLine := line.new(
         bar_index,
         orbHigh,
         bar_index + 1,
         orbHigh,
         extend = extend.right,
         color = highColor,
         style = highLineStyle,
         width = highWidth)

    if showMid
        currentMidLine := line.new(
             bar_index,
             orbMid,
             bar_index + 1,
             orbMid,
             extend = extend.right,
             color = midColor,
             style = midLineStyle,
             width = midWidth)
    else
        currentMidLine := na

    currentLowLine := line.new(
         bar_index,
         orbLow,
         bar_index + 1,
         orbLow,
         extend = extend.right,
         color = lowColor,
         style = lowLineStyle,
         width = lowWidth)

    if showOrbBox
        currentOrbBox := box.new(
             left = bar_index,
             top = orbHigh,
             right = bar_index + 1,
             bottom = orbLow,
             border_color = na,
             bgcolor = color.new(boxColor, boxTransparency))
    else
        currentOrbBox := na

else if inRange
    // Keep updating the range until the opening-range window closes.
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)
    orbMid = (orbHigh + orbLow) / 2.0

    if not na(currentHighLine)
        line.set_y1(currentHighLine, orbHigh)
        line.set_y2(currentHighLine, orbHigh)

    if showMid and not na(currentMidLine)
        line.set_y1(currentMidLine, orbMid)
        line.set_y2(currentMidLine, orbMid)

    if not na(currentLowLine)
        line.set_y1(currentLowLine, orbLow)
        line.set_y2(currentLowLine, orbLow)

    if showOrbBox and not na(currentOrbBox)
        box.set_right(currentOrbBox, bar_index + 1)
        box.set_top(currentOrbBox, orbHigh)
        box.set_bottom(currentOrbBox, orbLow)
        box.set_bgcolor(currentOrbBox, color.new(boxColor, boxTransparency))
````
