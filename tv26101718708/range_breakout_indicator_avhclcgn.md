# Range Breakout Indicator

- url: https://www.tradingview.com/script/AvHCLCGN-Range-Breakout-Indicator/
- type: indicator
- pine_id: PUB;a5ac5efa38de4ba08700aba85e181100
- version: 2.0

## Description

A simple range breakout strategy, where you select a [i]tracking[/i] time period and the [i]market[/i] time period. In the tracking time period, the high and the low values are marked, and a line is drawn for the entire trading range. A breakout above this range indicates a potential LONG position, while a breakout below this value indicates a SHORT position.

[b]Trading Theory[/b]

Institutions and HNIs are mostly active for a short time period where they place their bets, and then the market tries to follow the trend. For example, in the Indian market, typically big movements are likely to happen during the market opening cycle rather than the intraday session, which is typically due to some news/other factors. Example of typical important range breakout sessions are:

[list=1]
[*] 9:30 AM to 10:30 AM (IST, default) - Indian market opens, a big move in an index likely to set the trend of the day for the index.
[*] 6:30 PM to 7:30 PM (IST) - Global XAU New York Sessions opens, this is the time that decides the trend of the Gold for that trading session.
[/list]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copywright © 2026 ZenithClown (Debmalya Pramanik) | https://zenithclown.github.io/ | https://www.linkedin.com/in/dpramanik/

//@version=6

// ==================================================================
// OBJECTTIVE: Marks the High & Low of a Time Range for a Security
//
// A range breakout strategy involves identifying a price range and
// trading in the direction of a breakout once the price moves beyond
// the established support or resistance levels. This scripts tries to
// perform a back testing on the underlying security.
//
// Check https://github.com/growthio/tradingview for details.
// Check https://in.tradingview.com/u/ZenithClown/ for TV Profile.
// ==================================================================

indicator("Range Breakout", overlay = true)

import ZenithClown/rangeBreakout/6 as rangeBreakout

// ------------------------------------------------------------------
// INPUT(s) for Range Selection | Group Name: Range Window
// ------------------------------------------------------------------

trackTimePeriod = input.session(
    "0930-1030", "Session Time Range", group = "Range Window"
    , tooltip = "Time Range (HH:MM) to Track Security"
)

drawTimePeriod = input.session(
    "1030-1530", "Draw H/L Line for Range", group = "Range Window"
    , tooltip = "Time Range (HH:MM) to Draw High/Low Line"
)

maxLookbackDays = input.int(
    1, "Max Lookback Days", minval = 1, group = "Range Window"
    , tooltip = "Number of Historic Days to Compute"
)

// ------------------------------------------------------------------
// INPUT(s) for Color Selection | Group Name: Color & Window Config
// ------------------------------------------------------------------

showTrackingWindow = input.bool(
    false, "Highlight Tracking Window", group = "Color & Window Config"
)

highLineColor = input.color(
    color.new(#26A691, 0), "High Line Color"
    , group = "Color & Window Config", inline = "HLLINE"
)

lowLineColor = input.color(
    color.new(#EF5350, 0), "Low Line Color"
    , group = "Color & Window Config", inline = "HLLINE"
)

middleLineColor = input.color(
    color.black, "Middle Line Color"
    , group = "Color & Window Config", inline = "HLLINE"
)

rangeBgColor = input.color(
    color.new(color.yellow, 85), "Range Background Color"
    , group = "Color & Window Config"
)

// ------------------------------------------------------------------
// INPUT(s) for Volume Profiling | Group Name: Volume Settings
// ------------------------------------------------------------------
volumeMultiplier = input.float(
    1.5, "Volume Multiplier"
    , group = "Volume Settings", inline = "VOLS"
)

volumeLookback = input.int(
    5, "Volume Lookback Period"
    , group = "Volume Settings", inline = "VOLS"
)

// ------------------------------------------------------------------
// INPUT(s) for Entry/Exit Points | Group Name: Mark Entry/Exit
// ------------------------------------------------------------------
markLongPosition = input.bool(
    false, "Long Position"
    , group = "Mark Entry/Exit (experimental)", inline = "MEE"
)

markShortPosition = input.bool(
    false, "Short Position"
    , group = "Mark Entry/Exit (experimental)", inline = "MEE"
)

// ------------------------------------------------------------------
// Call `rangeBreakout()` and Draw on Chart with Overlay Setting
// ------------------------------------------------------------------
[rangeHi, rangeLo, inTrackRange] = rangeBreakout.markRange(
    trackTimePeriod, drawTimePeriod, highLineColor, lowLineColor, middleLineColor, maxLookbackDays
)

bgcolor(showTrackingWindow and inTrackRange ? rangeBgColor : na, title = "Tracking Window")

// ------------------------------------------------------------------
// Calculation of Target/Stop Loss and Mark the Value on Chart
// ------------------------------------------------------------------
[longBreakout, shortBreakout] = rangeBreakout.volumeConfirmation(
    trackTimePeriod, drawTimePeriod, maxLookbackDays, volumeLookback, volumeMultiplier
)

plotshape(
    longBreakout and markLongPosition, title = "Long Position"
    , style = shape.triangleup, text = "L"
    , location = location.belowbar, color = color.black, size = size.tiny
)

plotshape(
    shortBreakout and markShortPosition, title = "Short Position"
    , style = shape.triangledown, text = "S"
    , location = location.abovebar, color = color.black, size = size.tiny
)
````
