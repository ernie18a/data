# Smart Trend + Zones 

- url: https://www.tradingview.com/script/izua5dXx-Smart-Trend-Zones/
- type: indicator
- pine_id: PUB;5939fa6651f44729ace4445c9fac64f0
- version: 1.0

## Description

Smart Trend + Zones 

Smart Trend Zones is a clean trend-zone indicator designed to replace traditional single trendlines with adjustable sloped support and resistance zones.

The indicator automatically searches confirmed pivot highs and pivot lows to identify potential trend structures. Instead of drawing a thin line, it creates a filled zone around the trendline, helping account for normal price movement, wick reactions, and small differences between touch points.

The chart remains clean by displaying only active bullish and bearish zones and optional confirmed breakout signals.

Main Features
Bullish Support Zones

Bullish zones are created beneath price using rising pivot lows.

These zones may act as dynamic support while the bullish structure remains valid.

A bullish zone is considered broken only when a candle closes below the lower boundary of the zone.

When this happens:

A confirmed sell signal is displayed.
The broken bullish zone is removed from the chart.
A wick below the zone does not trigger a break.
Bearish Resistance Zones

Bearish zones are created above price using falling pivot highs.

These zones may act as dynamic resistance while the bearish structure remains valid.

A bearish zone is considered broken only when a candle closes above the upper boundary of the zone.

When this happens:

A confirmed buy signal is displayed.
The broken bearish zone is removed from the chart.
A wick above the zone does not trigger a break.
Confirmed Signals

Signals are generated only after the breakout candle has closed.

Buy signal: Candle closes above a bearish resistance zone.
Sell signal: Candle closes below a bullish support zone.

This prevents temporary intrabar movement and wick penetration from creating premature signals.

Signal appearance can be customized using:

Arrow, triangle, diamond, or circle markers.
Adjustable marker size.
Custom buy and sell colors.
Maximum number of historical signal markers.
How to Use the Indicator
1. Identify the Active Trend Zones

Green zones represent potential bullish support.

Red zones represent potential bearish resistance.

A zone extending toward the current price means the trend structure is still active.

2. Watch How Price Reacts

Price may:

Touch the zone and reject.
Consolidate near the zone.
Wick through the zone and recover.
Close completely outside the zone.

A wick through the zone does not automatically invalidate it. The candle must close beyond the outer edge.

3. Trading With the Zone

A bullish support zone can be used to look for:

Bullish rejection candles.
Continuation setups.
Pullback entries.
Higher-low formations.
Confluence with another support level.

A bearish resistance zone can be used to look for:

Bearish rejection candles.
Continuation setups.
Pullback entries.
Lower-high formations.
Confluence with another resistance level.
4. Trading the Breakout Signal

A buy signal means price has closed above an active bearish resistance zone.

A sell signal means price has closed below an active bullish support zone.

The signal confirms that the previous trend-zone structure has been invalidated. It does not guarantee that price will continue in the breakout direction.

For additional confirmation, traders may combine the signal with:

Market structure.
Volume.
Support and resistance.
Fair value gaps.
Order blocks.
Session highs and lows.
Higher-timeframe direction.
Recommended Settings

These settings provide a balanced starting point and keep the chart clean.

Trend Detection
Start year:                     2020
Start month:                    1
Start day:                      1
Pivot period:                   10
Pivot points to search:         3
Minimum pivot touches:          2
Minimum bars between anchors:   10
Minimum bars between touches:   5
Maximum candidate age:          2500 bars
Maximum slope:                  0 — disabled
Trend Zones
Show bullish support zones:     On
Show bearish resistance zones:  On
Zone width:                     5 ticks
Touch tolerance:                1 tick
Close-break buffer:             0 ticks
Maximum active zones per side:  2
Overlap tolerance:              1 zone width
Fill transparency:              82
Border transparency:            20
Border width:                   1

Suggested colors:

Bullish zone: Green
Bearish zone: Red
Break Signals
Show confirmed break signals:   On
Signal style:                   Arrow
Signal size:                    Small
Buy color:                      Green
Sell color:                     Red
Maximum signal markers:         200
Important Settings Explained
Pivot Period

Controls how sensitive the swing detection is.

Lower values create more pivots and more zones.
Higher values create fewer but more significant zones.

A value of 10 is a good balanced starting point.

Minimum Pivot Touches

Controls how many confirmed pivot points are required to validate a zone.

2 touches: More zones and earlier detection.
3 touches: More selective and usually stronger.
4 or more touches: Very selective, but zones may appear later.

The recommended starting value is 2. Traders wanting fewer zones can increase it to 3.

Zone Width

Controls the thickness of each zone using the symbol’s minimum tick size.

A wider zone allows more price movement around the trendline. A narrower zone requires more precise reactions.

The recommended starting value is 5 ticks, but this may need adjustment depending on the instrument.

Touch Tolerance

Allows a pivot to be counted as a touch when it is slightly away from the trendline.

The recommended value is 1 tick.

Close-Break Buffer

Requires price to close an additional number of ticks beyond the zone before confirming a break.

0 confirms the break immediately after a close outside the zone.
A higher value can reduce marginal or one-tick breakouts.
Maximum Active Zones Per Side

Limits how many bullish and bearish zones can remain visible simultaneously.

A value of 2 keeps the chart clean while still showing nearby trend structure.

Overlap Tolerance

Controls how close two zones can be before they are treated as overlapping.

The indicator removes or avoids redundant zones to reduce chart clutter.

Notes

Confirmed pivots require candles on both sides of the swing point. Because of this, new zones appear only after the pivot has been confirmed.

Signals are confirmed at candle close and do not trigger from temporary intrabar price movement.

Settings may need to be adjusted for different markets and timeframes. Instruments with larger volatility may require a wider zone or breakout buffer.

This indicator is intended as a market-structure and trend-analysis tool. It should not be used as a standalone trading system.

For educational purposes only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © elsrodriguez1

//@version=6
indicator("Smart Trend Zones ", shorttitle = "Trend Zone", overlay = true, max_bars_back = 5000, max_lines_count = 200, max_labels_count = 500)

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 1. INPUTS
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
string GROUP_DETECTION = "1. Trend Detection"
int startYear  = input.int(2020, "Start year", minval = 1970, maxval = 2100, group = GROUP_DETECTION)
int startMonth = input.int(1, "Start month", minval = 1, maxval = 12, group = GROUP_DETECTION)
int startDay   = input.int(1, "Start day", minval = 1, maxval = 31, group = GROUP_DETECTION)
int pivotPeriod = input.int(20, "Pivot period", minval = 2, maxval = 50, group = GROUP_DETECTION)
int pivotsToStore = input.int(8, "Pivot points to search", minval = 3, maxval = 20, group = GROUP_DETECTION)
int minimumTouches = input.int(2, "Minimum pivot touches", minval = 2, maxval = 5, group = GROUP_DETECTION)
int minimumAnchorBars = input.int(10, "Minimum bars between anchors", minval = 1, maxval = 500, group = GROUP_DETECTION)
int minimumTouchBars = input.int(5, "Minimum bars between touches", minval = 1, maxval = 500, group = GROUP_DETECTION)
int maximumCandidateAge = input.int(2500, "Maximum candidate age (bars)", minval = 100, maxval = 4500, group = GROUP_DETECTION)
float maximumSlopeTicks = input.float(0.0, "Maximum slope (ticks per bar, 0 = off)", minval = 0.0, step = 0.1, group = GROUP_DETECTION)

string GROUP_ZONES = "2. Trend Zones"
bool showBullishZones = input.bool(true, "Show bullish support zones", group = GROUP_ZONES)
bool showBearishZones = input.bool(true, "Show bearish resistance zones", group = GROUP_ZONES)
int zoneWidthTicks = input.int(8, "Zone width (ticks)", minval = 1, maxval = 1000, group = GROUP_ZONES)
int touchToleranceTicks = input.int(1, "Touch tolerance (ticks)", minval = 0, maxval = 100, group = GROUP_ZONES)
int breakoutBufferTicks = input.int(0, "Close-break buffer (ticks)", minval = 0, maxval = 100, group = GROUP_ZONES)
int maximumZonesPerSide = input.int(2, "Maximum active zones per side", minval = 1, maxval = 5, group = GROUP_ZONES)
float overlapTolerance = input.float(1.0, "Overlap tolerance (zone widths)", minval = 0.0, maxval = 5.0, step = 0.25, group = GROUP_ZONES)
color bullishZoneColor = input.color(color.lime, "Bullish zone color", group = GROUP_ZONES, inline = "bull")
color bearishZoneColor = input.color(color.red, "Bearish zone color", group = GROUP_ZONES, inline = "bear")
int zoneTransparency = input.int(82, "Fill transparency", minval = 0, maxval = 100, group = GROUP_ZONES)
int borderTransparency = input.int(20, "Border transparency", minval = 0, maxval = 100, group = GROUP_ZONES)
int borderWidth = input.int(1, "Border width", minval = 1, maxval = 4, group = GROUP_ZONES)

string GROUP_SIGNALS = "3. Break Signals"
bool showSignals = input.bool(true, "Show confirmed break signals", group = GROUP_SIGNALS)
string signalStyle = input.string("Triangle", "Signal style", options = ["Triangle", "Arrow", "Diamond", "Circle"], group = GROUP_SIGNALS)
string signalSize = input.string(size.small, "Signal size", options = [size.tiny, size.small, size.normal, size.large], group = GROUP_SIGNALS)
color buySignalColor = input.color(color.lime, "Buy color", group = GROUP_SIGNALS, inline = "signal")
color sellSignalColor = input.color(color.red, "Sell color", group = GROUP_SIGNALS, inline = "signal")
int maximumSignalMarkers = input.int(200, "Maximum signal markers", minval = 10, maxval = 500, group = GROUP_SIGNALS)

int startTime = timestamp(startYear, startMonth, startDay, 0, 0)
float tickSize = syminfo.mintick
float zoneWidth = zoneWidthTicks * tickSize
float touchTolerance = touchToleranceTicks * tickSize
float breakoutBuffer = breakoutBufferTicks * tickSize

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 2. PIVOT STORAGE
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
float pivotHigh = ta.pivothigh(pivotPeriod, pivotPeriod)
float pivotLow  = ta.pivotlow(pivotPeriod, pivotPeriod)

var array<float> highValues = array.new<float>(pivotsToStore, na)
var array<int> highBars = array.new<int>(pivotsToStore, na)
var array<float> lowValues = array.new<float>(pivotsToStore, na)
var array<int> lowBars = array.new<int>(pivotsToStore, na)

f_add_pivot(array<float> values, array<int> bars, float value, int pivotBar) =>
    array.unshift(values, value)
    array.unshift(bars, pivotBar)
    array.pop(values)
    array.pop(bars)

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 3. ACTIVE ZONE STORAGE
// Bullish: upper line touches pivot lows; zone extends below it.
// Bearish: lower line touches pivot highs; zone extends above it.
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
var array<line> bullishUpperLines = array.new<line>()
var array<line> bullishLowerLines = array.new<line>()
var array<linefill> bullishFills = array.new<linefill>()
var array<int> bullishTouches = array.new<int>()
var array<int> bullishLastTouchBars = array.new<int>()

var array<line> bearishUpperLines = array.new<line>()
var array<line> bearishLowerLines = array.new<line>()
var array<linefill> bearishFills = array.new<linefill>()
var array<int> bearishTouches = array.new<int>()
var array<int> bearishLastTouchBars = array.new<int>()

f_delete_zone(
    array<line> upperLines,
    array<line> lowerLines,
    array<linefill> fills,
    array<int> touches,
    array<int> lastTouchBars,
    int index) =>
    line upperLine = array.remove(upperLines, index)
    line lowerLine = array.remove(lowerLines, index)
    linefill zoneFill = array.remove(fills, index)
    array.remove(touches, index)
    array.remove(lastTouchBars, index)
    linefill.delete(zoneFill)
    line.delete(upperLine)
    line.delete(lowerLine)

f_find_overlap(array<line> referenceLines, float candidatePriceNow, float tolerancePrice) =>
    int overlapIndex = -1
    int zoneCount = array.size(referenceLines)
    if zoneCount > 0
        for i = 0 to zoneCount - 1
            float existingPriceNow = line.get_price(array.get(referenceLines, i), bar_index)
            if math.abs(existingPriceNow - candidatePriceNow) <= tolerancePrice
                overlapIndex := i
                break
    overlapIndex

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 4. CANDIDATE VALIDATION
// A zone is invalid if any confirmed close already crossed its outer edge.
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
f_bullish_path_valid(int oldestBar, float oldestPrice, float slope, float width) =>
    bool valid = true
    int barsBack = bar_index - oldestBar
    if barsBack > 0
        for offset = 0 to barsBack - 1
            int testBar = bar_index - offset
            float upperAtBar = oldestPrice + slope * (testBar - oldestBar)
            float lowerAtBar = upperAtBar - width
            if close[offset] < lowerAtBar
                valid := false
                break
    valid

f_bearish_path_valid(int oldestBar, float oldestPrice, float slope, float width) =>
    bool valid = true
    int barsBack = bar_index - oldestBar
    if barsBack > 0
        for offset = 0 to barsBack - 1
            int testBar = bar_index - offset
            float lowerAtBar = oldestPrice + slope * (testBar - oldestBar)
            float upperAtBar = lowerAtBar + width
            if close[offset] > upperAtBar
                valid := false
                break
    valid

f_count_bullish_touches(
    int oldestBar,
    float oldestPrice,
    float slope,
    float width,
    float tolerance,
    array<float> values,
    array<int> bars,
    int minBarsApart) =>
    int touchCount = 0
    int lastCountedBar = na
    int storedCount = array.size(bars)
    for step = 0 to storedCount - 1
        int index = storedCount - 1 - step
        int pivotBar = array.get(bars, index)
        float pivotPrice = array.get(values, index)
        if not na(pivotBar) and pivotBar >= oldestBar
            float upperAtPivot = oldestPrice + slope * (pivotBar - oldestBar)
            float lowerAtPivot = upperAtPivot - width
            bool insideZone = pivotPrice <= upperAtPivot + tolerance and pivotPrice >= lowerAtPivot - tolerance
            bool spaced = na(lastCountedBar) or pivotBar - lastCountedBar >= minBarsApart
            if insideZone and spaced
                touchCount += 1
                lastCountedBar := pivotBar
    touchCount

f_count_bearish_touches(
    int oldestBar,
    float oldestPrice,
    float slope,
    float width,
    float tolerance,
    array<float> values,
    array<int> bars,
    int minBarsApart) =>
    int touchCount = 0
    int lastCountedBar = na
    int storedCount = array.size(bars)
    for step = 0 to storedCount - 1
        int index = storedCount - 1 - step
        int pivotBar = array.get(bars, index)
        float pivotPrice = array.get(values, index)
        if not na(pivotBar) and pivotBar >= oldestBar
            float lowerAtPivot = oldestPrice + slope * (pivotBar - oldestBar)
            float upperAtPivot = lowerAtPivot + width
            bool insideZone = pivotPrice >= lowerAtPivot - tolerance and pivotPrice <= upperAtPivot + tolerance
            bool spaced = na(lastCountedBar) or pivotBar - lastCountedBar >= minBarsApart
            if insideZone and spaced
                touchCount += 1
                lastCountedBar := pivotBar
    touchCount

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 5. CONFIRMED CLOSE BREAKS
// Signals are created only on a closed candle beyond the full zone.
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
bool buySignal = false
bool sellSignal = false

if barstate.isconfirmed
    int bullishZoneCount = array.size(bullishLowerLines)
    if bullishZoneCount > 0
        for step = 0 to bullishZoneCount - 1
            int index = bullishZoneCount - 1 - step
            float lowerNow = line.get_price(array.get(bullishLowerLines, index), bar_index)
            if close < lowerNow - breakoutBuffer
                sellSignal := true
                f_delete_zone(bullishUpperLines, bullishLowerLines, bullishFills, bullishTouches, bullishLastTouchBars, index)

    int bearishZoneCount = array.size(bearishUpperLines)
    if bearishZoneCount > 0
        for step = 0 to bearishZoneCount - 1
            int index = bearishZoneCount - 1 - step
            float upperNow = line.get_price(array.get(bearishUpperLines, index), bar_index)
            if close > upperNow + breakoutBuffer
                buySignal := true
                f_delete_zone(bearishUpperLines, bearishLowerLines, bearishFills, bearishTouches, bearishLastTouchBars, index)

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 6. NEW CONFIRMED PIVOTS
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
bool newPivotLow = barstate.isconfirmed and bar_index >= pivotPeriod and not na(pivotLow) and time[pivotPeriod] >= startTime
bool newPivotHigh = barstate.isconfirmed and bar_index >= pivotPeriod and not na(pivotHigh) and time[pivotPeriod] >= startTime

if newPivotLow
    int pivotBar = bar_index - pivotPeriod
    f_add_pivot(lowValues, lowBars, pivotLow, pivotBar)

if newPivotHigh
    int pivotBar = bar_index - pivotPeriod
    f_add_pivot(highValues, highBars, pivotHigh, pivotBar)

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 7. UPDATE TOUCH COUNTS ON EXISTING ZONES
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
if newPivotLow and array.size(bullishUpperLines) > 0
    int pivotBar = bar_index - pivotPeriod
    for i = 0 to array.size(bullishUpperLines) - 1
        int lastTouchBar = array.get(bullishLastTouchBars, i)
        float upperAtPivot = line.get_price(array.get(bullishUpperLines, i), pivotBar)
        float lowerAtPivot = line.get_price(array.get(bullishLowerLines, i), pivotBar)
        bool insideZone = pivotLow <= upperAtPivot + touchTolerance and pivotLow >= lowerAtPivot - touchTolerance
        bool spaced = pivotBar - lastTouchBar >= minimumTouchBars
        if insideZone and spaced
            array.set(bullishTouches, i, array.get(bullishTouches, i) + 1)
            array.set(bullishLastTouchBars, i, pivotBar)

if newPivotHigh and array.size(bearishLowerLines) > 0
    int pivotBar = bar_index - pivotPeriod
    for i = 0 to array.size(bearishLowerLines) - 1
        int lastTouchBar = array.get(bearishLastTouchBars, i)
        float upperAtPivot = line.get_price(array.get(bearishUpperLines, i), pivotBar)
        float lowerAtPivot = line.get_price(array.get(bearishLowerLines, i), pivotBar)
        bool insideZone = pivotHigh >= lowerAtPivot - touchTolerance and pivotHigh <= upperAtPivot + touchTolerance
        bool spaced = pivotBar - lastTouchBar >= minimumTouchBars
        if insideZone and spaced
            array.set(bearishTouches, i, array.get(bearishTouches, i) + 1)
            array.set(bearishLastTouchBars, i, pivotBar)

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 8. BUILD THE BEST NEW BULLISH CANDIDATE
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
if newPivotLow and showBullishZones
    int newestBar = array.get(lowBars, 0)
    float newestPrice = array.get(lowValues, 0)

    bool candidateFound = false
    int bestOldestBar = na
    float bestOldestPrice = na
    float bestSlope = na
    int bestTouches = 0
    int bestSpan = 0

    for olderIndex = 1 to pivotsToStore - 1
        int oldestBar = array.get(lowBars, olderIndex)
        float oldestPrice = array.get(lowValues, olderIndex)

        if not na(oldestBar) and not na(oldestPrice)
            int span = newestBar - oldestBar
            bool risingLows = newestPrice > oldestPrice
            bool enoughSeparation = span >= minimumAnchorBars and bar_index - oldestBar <= maximumCandidateAge

            if risingLows and enoughSeparation
                float slope = (newestPrice - oldestPrice) / span
                float slopeInTicks = slope / tickSize
                bool slopeAllowed = maximumSlopeTicks == 0.0 or slopeInTicks <= maximumSlopeTicks
                bool pathValid = slopeAllowed and f_bullish_path_valid(oldestBar, oldestPrice, slope, zoneWidth)

                if pathValid
                    int touches = f_count_bullish_touches(oldestBar, oldestPrice, slope, zoneWidth, touchTolerance, lowValues, lowBars, minimumTouchBars)
                    bool betterCandidate = touches > bestTouches or (touches == bestTouches and span > bestSpan)
                    if touches >= minimumTouches and betterCandidate
                        candidateFound := true
                        bestOldestBar := oldestBar
                        bestOldestPrice := oldestPrice
                        bestSlope := slope
                        bestTouches := touches
                        bestSpan := span

    if candidateFound
        float upperAtNewest = bestOldestPrice + bestSlope * (newestBar - bestOldestBar)
        float lowerAtOldest = bestOldestPrice - zoneWidth
        float lowerAtNewest = upperAtNewest - zoneWidth
        float candidateUpperNow = bestOldestPrice + bestSlope * (bar_index - bestOldestBar)
        float overlapPrice = zoneWidth * overlapTolerance
        int overlapIndex = f_find_overlap(bullishUpperLines, candidateUpperNow, overlapPrice)
        bool addCandidate = true

        if overlapIndex >= 0
            int existingTouches = array.get(bullishTouches, overlapIndex)
            if bestTouches > existingTouches
                f_delete_zone(bullishUpperLines, bullishLowerLines, bullishFills, bullishTouches, bullishLastTouchBars, overlapIndex)
            else
                addCandidate := false

        if addCandidate
            line upperLine = line.new(
                 bestOldestBar, bestOldestPrice,
                 newestBar, upperAtNewest,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 color = color.new(bullishZoneColor, borderTransparency),
                 width = borderWidth)
            line lowerLine = line.new(
                 bestOldestBar, lowerAtOldest,
                 newestBar, lowerAtNewest,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 color = color.new(bullishZoneColor, borderTransparency),
                 width = borderWidth)
            linefill zoneFill = linefill.new(upperLine, lowerLine, color.new(bullishZoneColor, zoneTransparency))

            array.push(bullishUpperLines, upperLine)
            array.push(bullishLowerLines, lowerLine)
            array.push(bullishFills, zoneFill)
            array.push(bullishTouches, bestTouches)
            array.push(bullishLastTouchBars, newestBar)

            if array.size(bullishUpperLines) > maximumZonesPerSide
                f_delete_zone(bullishUpperLines, bullishLowerLines, bullishFills, bullishTouches, bullishLastTouchBars, 0)

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 9. BUILD THE BEST NEW BEARISH CANDIDATE
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
if newPivotHigh and showBearishZones
    int newestBar = array.get(highBars, 0)
    float newestPrice = array.get(highValues, 0)

    bool candidateFound = false
    int bestOldestBar = na
    float bestOldestPrice = na
    float bestSlope = na
    int bestTouches = 0
    int bestSpan = 0

    for olderIndex = 1 to pivotsToStore - 1
        int oldestBar = array.get(highBars, olderIndex)
        float oldestPrice = array.get(highValues, olderIndex)

        if not na(oldestBar) and not na(oldestPrice)
            int span = newestBar - oldestBar
            bool fallingHighs = newestPrice < oldestPrice
            bool enoughSeparation = span >= minimumAnchorBars and bar_index - oldestBar <= maximumCandidateAge

            if fallingHighs and enoughSeparation
                float slope = (newestPrice - oldestPrice) / span
                float slopeInTicks = math.abs(slope / tickSize)
                bool slopeAllowed = maximumSlopeTicks == 0.0 or slopeInTicks <= maximumSlopeTicks
                bool pathValid = slopeAllowed and f_bearish_path_valid(oldestBar, oldestPrice, slope, zoneWidth)

                if pathValid
                    int touches = f_count_bearish_touches(oldestBar, oldestPrice, slope, zoneWidth, touchTolerance, highValues, highBars, minimumTouchBars)
                    bool betterCandidate = touches > bestTouches or (touches == bestTouches and span > bestSpan)
                    if touches >= minimumTouches and betterCandidate
                        candidateFound := true
                        bestOldestBar := oldestBar
                        bestOldestPrice := oldestPrice
                        bestSlope := slope
                        bestTouches := touches
                        bestSpan := span

    if candidateFound
        float lowerAtNewest = bestOldestPrice + bestSlope * (newestBar - bestOldestBar)
        float upperAtOldest = bestOldestPrice + zoneWidth
        float upperAtNewest = lowerAtNewest + zoneWidth
        float candidateLowerNow = bestOldestPrice + bestSlope * (bar_index - bestOldestBar)
        float overlapPrice = zoneWidth * overlapTolerance
        int overlapIndex = f_find_overlap(bearishLowerLines, candidateLowerNow, overlapPrice)
        bool addCandidate = true

        if overlapIndex >= 0
            int existingTouches = array.get(bearishTouches, overlapIndex)
            if bestTouches > existingTouches
                f_delete_zone(bearishUpperLines, bearishLowerLines, bearishFills, bearishTouches, bearishLastTouchBars, overlapIndex)
            else
                addCandidate := false

        if addCandidate
            line lowerLine = line.new(
                 bestOldestBar, bestOldestPrice,
                 newestBar, lowerAtNewest,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 color = color.new(bearishZoneColor, borderTransparency),
                 width = borderWidth)
            line upperLine = line.new(
                 bestOldestBar, upperAtOldest,
                 newestBar, upperAtNewest,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 color = color.new(bearishZoneColor, borderTransparency),
                 width = borderWidth)
            linefill zoneFill = linefill.new(upperLine, lowerLine, color.new(bearishZoneColor, zoneTransparency))

            array.push(bearishUpperLines, upperLine)
            array.push(bearishLowerLines, lowerLine)
            array.push(bearishFills, zoneFill)
            array.push(bearishTouches, bestTouches)
            array.push(bearishLastTouchBars, newestBar)

            if array.size(bearishUpperLines) > maximumZonesPerSide
                f_delete_zone(bearishUpperLines, bearishLowerLines, bearishFills, bearishTouches, bearishLastTouchBars, 0)

//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
// 10. CLEAN, CUSTOMIZABLE SIGNALS
// Labels support dynamic style and size and do not use Pine plot counts.
//â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
var array<label> signalMarkers = array.new<label>()

f_add_signal_marker(bool isBuy) =>
    string markerStyle = switch signalStyle
        "Arrow"   => isBuy ? label.style_arrowup : label.style_arrowdown
        "Diamond" => label.style_diamond
        "Circle"  => label.style_circle
        => isBuy ? label.style_triangleup : label.style_triangledown

    string markerLocation = isBuy ? yloc.belowbar : yloc.abovebar
    color markerColor = isBuy ? buySignalColor : sellSignalColor

    label marker = label.new(
         x = bar_index,
         y = na,
         text = "",
         xloc = xloc.bar_index,
         yloc = markerLocation,
         style = markerStyle,
         color = markerColor,
         textcolor = markerColor,
         size = signalSize)

    array.push(signalMarkers, marker)
    if array.size(signalMarkers) > maximumSignalMarkers
        label.delete(array.shift(signalMarkers))

if showSignals and buySignal
    f_add_signal_marker(true)

if showSignals and sellSignal
    f_add_signal_marker(false)

// Alerts trigger only on confirmed candle-close breaks.
alertcondition(buySignal, "UTSZ Confirmed Buy", "A candle closed above a bearish trend zone.")
alertcondition(sellSignal, "UTSZ Confirmed Sell", "A candle closed below a bullish trend zone.")
````
