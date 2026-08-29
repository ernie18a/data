<!-- tradingview-pine-id: PUB;c51928d88ce44b109bbedb36325a6467 -->
<!-- tradingviewscripts-format: 1 -->
# AdminsMoney10AMC

Source: https://www.tradingview.com/script/L97KQbbj-AdminsMoney10AMC/

## Description

AdminsMoney10AMC Model

The AdminsMoney10AMC is a discretionary intraday trading model built around the 10:00 AM New York 1-minute candle on MNQ. The model is not an entry strategy by itself. It identifies a Point of Interest (POI) where I begin looking for my execution model.

Market

* MNQ
* 1-Minute Chart
* 10:00 AM New York Time

Step 1

Wait for the 10:00–10:01 AM New York candle to close.

Do not anticipate the candle.

Step 2

Use the candle body only.

Ignore both wicks.

If the 10:00 candle closes bullish:

* Mark the OPEN of the candle (bottom of the body).

If the 10:00 candle closes bearish:

* Mark the OPEN of the candle (top of the body).

This price becomes the Point of Interest (POI).

Step 3

Allow price to move away from the POI.

There is no trade simply because the 10:00 candle has closed.

Step 4

Wait for price to return and manipulate the POI.

A valid manipulation includes:

* Wick touching the level
* Wick trading through the level
* Candle body touching the level
* Candle body trading through the level
* Candle closing through the level

Only the first manipulation is considered.

Step 5

The POI is not an entry.

Once price returns to the POI, I look for my execution model.

Examples include:

* Aggressive 1-minute iFVG
* Displacement
* MSS
* BOS
* Liquidity Sweep
* SMT
* Higher Timeframe Confluence

If no confirmation develops, there is no trade.

Risk Management

Trades should align with higher-timeframe bias.

For bullish setups:

* Enter after bullish confirmation from the POI.
* Stop goes below the previous 1-minute candle’s wick.

For bearish setups:

* Enter after bearish confirmation from the POI.
* Stop goes above the previous 1-minute candle’s wick.

The stop is determined by structure rather than a fixed number of points.

---

## Source Code

````pine
//@version=6
indicator("AdminsMoney10AMC", overlay = true, max_labels_count = 50)

// Always calculate using New York time.
string NY_TIMEZONE = "America/New_York"

// New York date/time values.
int nyYear      = year(time, NY_TIMEZONE)
int nyMonth     = month(time, NY_TIMEZONE)
int nyDay       = dayofmonth(time, NY_TIMEZONE)
int nyHour      = hour(time, NY_TIMEZONE)
int nyMinute    = minute(time, NY_TIMEZONE)
int nyWeek      = weekofyear(time, NY_TIMEZONE)

// Unique identifiers for detecting a new day and new week.
int nyDate      = nyYear * 10000 + nyMonth * 100 + nyDay
int nyWeekId    = nyYear * 100 + nyWeek

bool newNyDay  = not na(nyDate[1]) and nyDate != nyDate[1]
bool newNyWeek = not na(nyWeekId[1]) and nyWeekId != nyWeekId[1]

// The one-minute candle opening at 10:00 AM New York time.
bool isTenAmCandle = nyHour == 10 and nyMinute == 0

// Current day's active level.
var float tenAmLevel = na
var int tenAmBarIndex = na
var bool retestMarked = false

// Store only the current week's markers.
var array<label> weeklyMarkers = array.new<label>()

// Delete every marker from the prior week.
if newNyWeek
    if array.size(weeklyMarkers) > 0
        for i = 0 to array.size(weeklyMarkers) - 1
            label.delete(array.get(weeklyMarkers, i))

    array.clear(weeklyMarkers)

    tenAmLevel := na
    tenAmBarIndex := na
    retestMarked := false

// Reset the active setup at the beginning of each New York day.
// Existing markers from earlier in the same week stay visible.
if newNyDay
    tenAmLevel := na
    tenAmBarIndex := na
    retestMarked := false

// Mark the completed 10:00 AM candle's body level.
//
// Bullish candle:
// Open = bottom of body.
//
// Bearish candle:
// Open = top of body.
//
// In both cases, the required level is the candle's open.
if isTenAmCandle and barstate.isconfirmed
    tenAmLevel := open
    tenAmBarIndex := bar_index
    retestMarked := false

    label tenAmSquare = label.new(
         x = bar_index,
         y = tenAmLevel,
         text = "",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_square,
         color = color.black,
         textcolor = color.black,
         size = size.small
     )

    array.push(weeklyMarkers, tenAmSquare)

// Any later manipulation counts as a retest:
// wick touch, body touch, crossing through, or closing through.
bool isLaterCandle =
     not na(tenAmBarIndex) and
     bar_index > tenAmBarIndex

bool touchesLevel =
     not na(tenAmLevel) and
     low <= tenAmLevel and
     high >= tenAmLevel

// Mark only the first retest for that day.
if isLaterCandle and touchesLevel and not retestMarked
    retestMarked := true

    label retestCircle = label.new(
         x = bar_index,
         y = tenAmLevel,
         text = "",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_circle,
         color = color.black,
         textcolor = color.black,
         size = size.small
     )

    array.push(weeklyMarkers, retestCircle)
````
