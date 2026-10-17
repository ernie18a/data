# Fixed Range / Donchian Channel with price projections

- url: https://www.tradingview.com/script/AbJipT5f-Fixed-Range-Donchian-Channel-with-price-projections/
- type: indicator
- pine_id: PUB;a11607b83f8a4c7abd790f969bf828a6
- version: 2.0

## Description

[b]## Fixed Range / Donchian Channel[/b]

A versatile channel indicator combining traditional Donchian Channels with adaptive fixed-range logic.

This tool is designed to help traders visualise structured price movement using either:

* Dynamic Donchian breakout ranges, or
* Fixed-width channels that remain level until price forces a reset.

Unlike standard volatility bands that continuously expand and contract every bar, the Fixed Range mode creates stable price zones that only shift when price exceeds the current boundary. This produces cleaner structure and makes recurring market ranges easier to identify.

[b]### Features[/b]

* Fixed Range mode using:

  * Points
  * Percentage
  * ATR
* Traditional Donchian Channel mode
* Locked ATR logic:

  * ATR is calculated only when the channel resets
  * Prevents band distortion and keeps channel widths stable
* Midline and quarter divisions
* Configurable extension levels
* Clean visual structure suitable for trend and range analysis

[b]### How It Works[/b]

[b]#### Fixed Range Mode[/b]

The channel maintains a constant width until price breaks either the upper or lower boundary.

When a breakout occurs:

* The channel resets from the breakout point
* A new fixed range is calculated
* The new range remains locked until the next reset

This creates staircase-like market structure that can help identify:

* Trend continuation
* Volatility expansion
* Recurring price intervals
* Structured pullbacks

[b]#### ATR Mode[/b]

Most ATR-based indicators recalculate every bar, causing channel widths to constantly fluctuate.

This script uses a different approach:

* ATR is only recalculated during a reset event
* The channel width then remains fixed
* Produces cleaner and more level price structures

This makes ATR behave more like a true structural range rather than a continuously moving volatility envelope.

[b]### Suggested Usage[/b]

Market behaviour is fractal in nature. Prices often move in repeating ranges and waves within waves.

Examples commonly observed:

* Forex intraday:

  * 10, 20, 50, 100 pip movements
  * 0.2%, 0.5%, 1% ranges
* Indices such as SPX:

  * 3%, 5%, 10% swings on higher timeframes

This indicator helps visualise these recurring structures across multiple scales.

Many traders may find it useful for:

* Trend structure analysis
* Pullback zones
* Breakout continuation
* Mean reversion areas
* Multi-timeframe market mapping

[b]### Power tip[/b]
With the fixed range option you can use the standard Tradingview fib extension with ease. Just set it once for the range and then just keep dragging it to new levels
Swith off the extension lines if you go for this method

[b]### Notes[/b]

* Fixed Range mode is intentionally non-reactive between resets.
* ATR mode behaves differently from standard ATR bands by design.
* Donchian mode functions as a traditional rolling highest/lowest channel.

## Source Code

````pine
//@version=6
indicator("Fixed Range / Donchian Channel", overlay = true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//──────────────────────────────────────────
// Channel Mode
//──────────────────────────────────────────
channelMode = input.string(
     "Fixed Range",
     title   = "Channel Mode",
     options = ["Fixed Range", "Donchian"]
)

//──────────────────────────────────────────
// Fixed Range Calculation Type
//──────────────────────────────────────────
rangeType = input.string(
     "Points",
     title   = "Fixed Range Type",
     options = ["Points", "Percentage", "ATR"],
     tooltip = "Points      → Fixed price distance\n" +
               "Percentage  → Percentage of reset price\n" +
               "ATR         → ATR locked at reset event"
)

//──────────────────────────────────────────
// Fixed Range Settings
//──────────────────────────────────────────
pointsRange = input.float(
     10,
     title = "Fixed Range (Points)",
     step  = 0.1
)

percentRange = input.float(
     1.0,
     title = "Fixed Range (%)",
     step  = 0.1
)

atrLength = input.int(
     14,
     title = "ATR Length",
     minval = 1
)

atrMultiplier = input.float(
     1.0,
     title = "ATR Multiplier",
     step  = 0.1
)

//──────────────────────────────────────────
// Donchian Settings
//──────────────────────────────────────────
donchianLength = input.int(
     60,
     title = "Donchian Length",
     minval = 1
)

//──────────────────────────────────────────
// Display Settings
//──────────────────────────────────────────
groupDisplay = "Display Settings"

lineColor = input.color(
     color.new(color.maroon, 20),
     "Line Color",
     group = groupDisplay
)

fillColor = input.color(
     color.new(color.maroon, 95),
     "Fill Color",
     group = groupDisplay
)

showMidline = input.bool(
     true,
     "Show Midline",
     group = groupDisplay
)

showQuarterLines = input.bool(
     true,
     "Show Quarter Divisions",
     group = groupDisplay
)
showEighthLines = input.bool(
     true,
     "Show 1/8 Internal Lines",
     group = groupDisplay
)
showExtensions = input.bool(
     true,
     "Show Extensions",
     group = groupDisplay
)

extensionPercent = input.int(
     25,
     "Extension %",
     options = [25, 50, 100],
     group = groupDisplay
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Current ATR
atrValue = ta.atr(atrLength)

// Persistent channel boundaries
var float channelHigh = na
var float channelLow  = na

// Locked range value
// IMPORTANT:
// ATR and Percentage values are ONLY recalculated
// when a channel reset occurs.
var float lockedRange = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RANGE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Convert point input into price distance
pointsDistance = pointsRange * syminfo.mintick * 10.0

// Function to calculate a new locked range
calculateRange(_referencePrice) =>
    switch rangeType
        "Points"     => pointsDistance
        "Percentage" => _referencePrice * percentRange / 100
        "ATR"        => atrValue * atrMultiplier
        => pointsDistance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIXED RANGE LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if channelMode == "Fixed Range"

    // Initialisation
    if na(channelHigh)
        channelHigh := high
        channelLow  := low

        // Lock initial range
        lockedRange := calculateRange(close)

    //──────────────────────────────────────
    // Upper Breakout
    //──────────────────────────────────────
    else if high >= channelHigh

        channelHigh := high
        channelLow  := channelHigh - lockedRange

        // Recalculate locked range ONLY at reset
        lockedRange := calculateRange(channelHigh)

    //──────────────────────────────────────
    // Lower Breakout
    //──────────────────────────────────────
    else if low <= channelLow

        channelLow  := low
        channelHigh := channelLow + lockedRange

        // Recalculate locked range ONLY at reset
        lockedRange := calculateRange(channelLow)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DONCHIAN LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

else

    channelHigh := ta.highest(high, donchianLength)
    channelLow  := ta.lowest(low, donchianLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DERIVED LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

channelRange = channelHigh - channelLow

midline =
     showMidline
     ? (channelHigh + channelLow) / 2
     : na

upperQuarter =
     showQuarterLines
     ? channelLow + channelRange * 0.75
     : na

lowerQuarter =
     showQuarterLines
     ? channelLow + channelRange * 0.25
     : na

//──────────────────────────────────────────
// Extensions
//──────────────────────────────────────────
extensionSize = channelRange * extensionPercent / 100

upperExtension1 =
     showExtensions
     ? channelHigh + extensionSize
     : na

lowerExtension1 =
     showExtensions
     ? channelLow - extensionSize
     : na

upperExtension2 =
     showExtensions
     ? channelHigh + extensionSize * 2
     : na

lowerExtension2 =
     showExtensions
     ? channelLow - extensionSize * 2
     : na
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INTERNAL 1/8 DIVISION LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━



// Softer version of main line color
eighthLineColor = color.new(lineColor, 70)

// 1/8 interval size
eighthStep = channelRange / 8

// Internal levels
eighth1 = showEighthLines ? channelLow + eighthStep * 1 : na
eighth2 = showEighthLines ? channelLow + eighthStep * 2 : na
eighth3 = showEighthLines ? channelLow + eighthStep * 3 : na
eighth4 = showEighthLines ? channelLow + eighthStep * 4 : na
eighth5 = showEighthLines ? channelLow + eighthStep * 5 : na
eighth6 = showEighthLines ? channelLow + eighthStep * 6 : na
eighth7 = showEighthLines ? channelLow + eighthStep * 7 : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1/8 INTERNAL LINE PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     eighth1,
     title   = "1/8",
     color   = eighthLineColor,
     linewidth = 1,
     display = display.all - display.status_line
)

plot(
     eighth2,
     title   = "2/8",
     color   = eighthLineColor,
     linewidth = 1,
     display = display.all - display.status_line
)

plot(
     eighth3,
     title   = "3/8",
     color   = eighthLineColor,
     linewidth = 1,
     display = display.all - display.status_line
)

plot(
     eighth4,
     title   = "4/8",
     color   = eighthLineColor,
     linewidth = 1,
     display = display.all - display.status_line
)

plot(
     eighth5,
     title   = "5/8",
     color   = eighthLineColor,
     linewidth = 1,
     display = display.all - display.status_line
)

plot(
     eighth6,
     title   = "6/8",
     color   = eighthLineColor,
     linewidth = 1,
     display = display.all - display.status_line
)

plot(
     eighth7,
     title   = "7/8",
     color   = eighthLineColor,
     linewidth = 1,
     display = display.all - display.status_line
)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotHigh = plot(
     channelHigh,
     title     = "Channel High",
     color     = lineColor,
     linewidth = 2,
     display   = display.all - display.status_line
)

plotLow = plot(
     channelLow,
     title     = "Channel Low",
     color     = lineColor,
     linewidth = 2,
     display   = display.all - display.status_line
)

// Midline
plot(
     midline,
     title     = "Midline",
     color     = lineColor,
     linewidth = 2
)

// Quarter Levels
plot(
     upperQuarter,
     title     = "Upper Quarter",
     color     = lineColor,
     linewidth = 1,
     display   = display.all - display.status_line
)

plot(
     lowerQuarter,
     title     = "Lower Quarter",
     color     = lineColor,
     linewidth = 1,
     display   = display.all - display.status_line
)

// Extensions
plot(
     upperExtension1,
     title     = "Upper Extension 1",
     color     = lineColor,
     linewidth = 1,
     display   = display.all - display.status_line
)

plot(
     lowerExtension1,
     title     = "Lower Extension 1",
     color     = lineColor,
     linewidth = 1,
     display   = display.all - display.status_line
)

plot(
     upperExtension2,
     title     = "Upper Extension 2",
     color     = lineColor,
     linewidth = 1,
     display   = display.all - display.status_line
)

plot(
     lowerExtension2,
     title     = "Lower Extension 2",
     color     = lineColor,
     linewidth = 1,
     display   = display.all - display.status_line
)

// Channel Fill
fill(plotHigh, plotLow, color = fillColor)
````
