# Crypto Intraday Engine

- url: https://www.tradingview.com/script/yQdPgJ6s-Crypto-Intraday-Engine/
- type: indicator
- pine_id: PUB;276c79157342425c8b5b68d22b1cc77d
- version: 1.0

## Description

Crypto Intraday Engine is a market-structure indicator designed specifically for the continuous, 24-hour nature of cryptocurrency markets.
The script organizes intraday market information and answers three clear questions:
• What is the current market context?
• Where is price located relative to the nearest structural zones?
• What structural event is currently being observed?
The answers are displayed in a compact dashboard:
CONTEXT
LOCATION
STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ ORIGINALITY AND PURPOSE
Crypto Intraday Engine combines four market concepts:
• UTC Daily VWAP;
• UTC Opening Range;
• ATR-adjusted zones based on confirmed pivots;
• closed-bar price-reaction observation.
These elements are not simply placed together on one chart as separate indicators. They operate as one connected analytical sequence.
VWAP defines the direction of the current market context.
Opening Range shows whether that context has gained additional intraday strength.
Confirmed pivot zones define the nearest structural location of price.
The reaction-observation mechanism describes what happens after price interacts with that zone.
The dashboard translates the entire sequence into three intuitive layers:
Context → Location → Status
The purpose of this combination is to help users analyze intraday structure through one consistent framework instead of interpreting several unrelated tools independently.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟡 UTC DAILY VWAP
The script calculates a volume-weighted average price from the beginning of each UTC day.
The calculation uses cumulative values of:
• HLC3 price;
• trading volume;
• time elapsed since 00:00 UTC.
Daily VWAP acts as the central reference for determining market context.
Cryptocurrency markets operate continuously and do not have one universal exchange session. Using 00:00 UTC provides a consistent daily reset that can be applied across different cryptocurrency instruments and exchanges.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌡 ATR-BASED NEUTRAL AREA
Price is not classified as Bullish or Bearish immediately after crossing VWAP.
The indicator creates a neutral area around Daily VWAP using a configurable multiple of Average True Range.
Default value: 0.20 ATR
This area adjusts to current volatility and reduces frequent context changes when price fluctuates close to VWAP.
The dashboard can display the following context states:
• Strong Bullish;
• Bullish;
• Neutral;
• Bearish;
• Strong Bearish.
Bullish context means that the closing price is above Daily VWAP and outside the ATR-based neutral area.
Bearish context means that the closing price is below Daily VWAP and outside the ATR-based neutral area.
Neutral context means that price remains within the volatility-adjusted area surrounding VWAP.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟧 UTC OPENING RANGE
The Opening Range is calculated from the first part of each UTC day.
Available periods:
• 15 minutes;
• 30 minutes;
• 60 minutes.
Default value: 30 minutes
Opening Range adds a second layer of information to the context defined by VWAP.
After the Opening Range is complete:
• Bullish context becomes Strong Bullish when price closes above the Opening Range high;
• Bearish context becomes Strong Bearish when price closes below the Opening Range low.
This makes it possible to distinguish a standard directional context from a situation in which price has also moved beyond the initial range of the UTC day.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟢 SUPPORT AND 🔴 RESISTANCE ZONES
Support and Resistance zones are created from confirmed pivot lows and pivot highs.
A pivot is confirmed only after the required number of candles has formed on both sides of the pivot point.
Support zones extend upward from confirmed pivot lows.
Resistance zones extend downward from confirmed pivot highs.
The vertical depth of each zone is calculated using ATR rather than a fixed number of price points.
Default zone depth: 0.60 ATR
This allows the zone dimensions to adapt to:
• different cryptocurrency prices;
• changes in market volatility;
• different intraday timeframes.
The script stores recent confirmed zones and displays:
• the nearest valid Support zone at or below the current price;
• the nearest valid Resistance zone at or above the current price.
A zone is removed when a candle closes beyond its outer boundary by more than the configured ATR buffer.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 PRICE LOCATION
The Location row shows where the current candle is positioned relative to the nearest valid structural zones.
Possible values:
• At Support;
• At Resistance;
• Between Zones;
• Compressed Area;
• No Zone.
This row helps users understand where price is located within the current market structure.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
↔️ COMPRESSED AREAS
The indicator measures the distance between the nearest Support and Resistance zones.
When this distance is below the configured ATR threshold, the area is classified as compressed.
Default minimum distance: 0.25 ATR
Overlapping zones are also classified as a compressed area.
The dashboard displays:
Location: Compressed Area
Status: Zones Close Together
This status indicates that the nearest structural boundaries are located within a relatively narrow range adjusted for current volatility.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔎 CLOSED-BAR REACTION OBSERVATION
The script contains a sequential mechanism for observing price behavior after price reaches a structural zone.
Support observation
Observation of a Support zone can begin when:
• the market context is Bullish;
• price reaches the nearest Support zone;
• Support and Resistance are not in a compressed area;
• the zone has not already been evaluated by the algorithm.
A Support Reaction is detected when a subsequent closed candle returns above:
• the upper boundary of the Support zone;
• UTC Daily VWAP.
Resistance observation
The opposite conditions are applied to Resistance zones.
Observation can begin when:
• the market context is Bearish;
• price reaches the nearest Resistance zone;
• Support and Resistance are not in a compressed area;
• the zone has not already been evaluated by the algorithm.
A Resistance Reaction is detected when a subsequent closed candle returns below:
• the lower boundary of the Resistance zone;
• UTC Daily VWAP.
The number of candles available for observation is controlled by the Reaction Observation Window parameter.
Default value: 3 closed candles
Each zone is evaluated once. This prevents the same structural area from repeatedly generating identical states.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 INDICATOR DASHBOARD
The dashboard is designed to be read from top to bottom.
🧭 CONTEXT
Shows the directional relationship between:
• closing price;
• UTC Daily VWAP;
• the ATR-based neutral area;
• the completed Opening Range.
Possible values:
• Strong Bullish;
• Bullish;
• Neutral;
• Bearish;
• Strong Bearish.
📍 LOCATION
Shows the position of price relative to the nearest valid zones.
Possible values:
• At Support;
• At Resistance;
• Between Zones;
• Compressed Area;
• No Zone.
🔎 STATUS
Describes the current structural condition or observation stage.
Possible states include:
• Monitoring Market;
• Monitoring Support;
• Monitoring Resistance;
• Observing Support Reaction;
• Observing Resistance Reaction;
• Support Reaction Detected;
• Resistance Reaction Detected;
• Bullish Context at Resistance;
• Bearish Context at Support;
• Zones Close Together;
• Context Changed;
• Zone Invalidated;
• Reaction Window Expired;
• Support Already Evaluated;
• Resistance Already Evaluated.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 COLOR LOGIC
Dashboard colors are used to visually separate different types of information:
• Green identifies Bullish context or Support;
• Red identifies Bearish context or Resistance;
• Blue identifies active observation or a detected reaction;
• Orange identifies a change, compression, or structural warning;
• Gray identifies a neutral monitoring state.
The color system helps users read the dashboard more quickly and distinguish between different categories of information.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠 HOW TO USE THE INDICATOR
Crypto Intraday Engine is designed for standard candlestick charts of cryptocurrency pairs.
Recommended timeframe range: 3 to 15 minutes
A 5-minute chart is a practical starting point for observing the complete indicator workflow.
Read the dashboard in the following order:
1. Context shows the broader intraday environment.
2. Location shows where price is positioned relative to the nearest structure.
3. Status describes the structural event currently being observed or already detected.
The chart displays:
• UTC Daily VWAP;
• UTC Opening Range;
• the nearest Support zone;
• the nearest Resistance zone;
• a compact informational dashboard.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ INPUTS
OPENING RANGE, MINUTES
Defines the duration of the Opening Range calculated from 00:00 UTC.
Available values:
• 15;
• 30;
• 60.
ATR LENGTH
Defines the Average True Range period used to calculate volatility-adjusted distances and zone dimensions.
PIVOT LEFT AND PIVOT RIGHT
Define how many candles must form to the left and right of a pivot before it is confirmed.
Higher values generally create fewer zones while making them broader and more structurally significant.
Lower values generally create more frequent local zones.
ZONE DEPTH, ATR
Defines the vertical depth of Support and Resistance zones.
ZONE INVALIDATION BUFFER, ATR
Defines how far a candle must close beyond a zone boundary before that zone is removed.
MINIMUM GAP BETWEEN ZONES, ATR
Defines the distance at which the nearest Support and Resistance zones are classified as a compressed area.
VWAP NEUTRAL DISTANCE, ATR
Defines the size of the neutral area surrounding UTC Daily VWAP.
REACTION OBSERVATION WINDOW
Defines the number of closed candles during which a reaction is observed after price reaches a structural zone.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏱ CONFIRMATION AND REAL-TIME BEHAVIOR
Dashboard values and reaction events are updated using closed candles.
Pivot zones require confirmation.
A zone appears only after the configured number of Pivot Right candles has completed.
The zone is visually anchored to the original pivot candle, but in real time it becomes available only after confirmation.
This is important to consider when reviewing historical charts.
Daily VWAP and Opening Range reset at 00:00 UTC.
Support and Resistance zones do not automatically reset at the beginning of a new UTC day.
They remain available until:
• price invalidates the zone;
• the zone is removed because of the internal zone-storage limit.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS
Crypto Intraday Engine uses mechanical definitions of:
• market context;
• confirmed pivots;
• Support and Resistance zones;
• zone-removal conditions;
• structural reactions.
These definitions may differ from a user’s discretionary interpretation of market structure.
A detected reaction means that the predefined closed-bar conditions have been met.
Subsequent price behavior may differ depending on the instrument, timeframe, liquidity, exchange, and current market volatility.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 INFORMATIONAL ALERTS
Available alerts correspond to structural events:
• price reached a Support zone;
• price reached a Resistance zone;
• Support Reaction Detected;
• Resistance Reaction Detected;
• Context Changed;
• Zone Invalidated;
• Reaction Window Expired;
• Zones Close Together.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📘 SUMMARY
Crypto Intraday Engine brings intraday context, structural price location, and closed-bar reactions together in one consistent, sequential, and visually intuitive framework for analyzing cryptocurrency markets.

## Source Code

````pine
//@version=6
indicator(
     "MarketStructureLab - Crypto Intraday Engine",
     shorttitle = "Crypto Intraday",
     overlay = true,
     max_bars_back = 5000,
     max_labels_count = 10,
     max_boxes_count = 5
)

//=============================================================================
// CRYPTO INTRADAY ENGINE v2.1
//
// Educational market-structure indicator for crypto.
//
// Displays:
// - UTC Daily VWAP
// - UTC Opening Range
// - Nearest Support zone
// - Nearest Resistance zone
// - Context
// - Location
// - Status
//
// Does not create:
// - Buy or Sell signals
// - Entry levels
// - Stop levels
// - Target levels
// - Risk/Reward calculations
// - Trade plans
//=============================================================================


//=============================================================================
// INPUTS
//=============================================================================

string GROUP_MAIN = "Main"

int openingRangeMinutes = input.int(
     30,
     "Opening Range, minutes",
     options = [15, 30, 60],
     group = GROUP_MAIN
)

int atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = GROUP_MAIN
)

bool showVWAP = input.bool(
     true,
     "Show UTC Daily VWAP",
     group = GROUP_MAIN
)

bool showOpeningRange = input.bool(
     true,
     "Show Opening Range",
     group = GROUP_MAIN
)

bool showZones = input.bool(
     true,
     "Show Support and Resistance",
     group = GROUP_MAIN
)

bool showDashboard = input.bool(
     true,
     "Show Dashboard",
     group = GROUP_MAIN
)


string GROUP_ZONES = "Zones"

int pivotLeft = input.int(
     8,
     "Pivot Left",
     minval = 1,
     maxval = 100,
     group = GROUP_ZONES
)

int pivotRight = input.int(
     5,
     "Pivot Right",
     minval = 1,
     maxval = 100,
     group = GROUP_ZONES
)

float zoneDepthATR = input.float(
     0.60,
     "Zone Depth, ATR",
     minval = 0.05,
     step = 0.05,
     group = GROUP_ZONES
)

float invalidationBufferATR = input.float(
     0.10,
     "Zone Invalidation Buffer, ATR",
     minval = 0.0,
     step = 0.05,
     group = GROUP_ZONES
)

float minimumZoneGapATR = input.float(
     0.25,
     "Minimum Gap Between Zones, ATR",
     minval = 0.0,
     step = 0.05,
     tooltip = "Marks the area as compressed when Support and Resistance are too close.",
     group = GROUP_ZONES
)


string GROUP_CONTEXT = "Context"

float neutralDistanceATR = input.float(
     0.20,
     "VWAP Neutral Distance, ATR",
     minval = 0.0,
     step = 0.05,
     group = GROUP_CONTEXT
)

int reactionWindowBars = input.int(
     3,
     "Reaction Observation Window",
     minval = 1,
     maxval = 10,
     tooltip = "Number of closed candles used to observe a reaction after price reaches a zone.",
     group = GROUP_CONTEXT
)


//=============================================================================
// INTERNAL SETTINGS
//=============================================================================

int MAX_STORED_ZONES = 40
int ZONE_FORWARD_BARS = 20
int ZONE_LABEL_FORWARD_BARS = 2

int ZONE_SUPPORT = 1
int ZONE_RESISTANCE = -1

int WATCH_NONE = 0
int WATCH_SUPPORT = 1
int WATCH_RESISTANCE = -1

int EVENT_NONE = 0
int EVENT_SUPPORT_REACTION = 1
int EVENT_RESISTANCE_REACTION = 2
int EVENT_CONTEXT_CHANGED = 3
int EVENT_ZONE_INVALIDATED = 4
int EVENT_WINDOW_EXPIRED = 5


//=============================================================================
// COLORS
//=============================================================================

color COLOR_BULLISH = color.rgb(16, 185, 129)
color COLOR_BEARISH = color.rgb(240, 93, 94)
color COLOR_INFORMATION = color.rgb(56, 189, 248)
color COLOR_WARNING = color.rgb(245, 158, 11)
color COLOR_NEUTRAL = color.rgb(148, 163, 184)

color COLOR_VWAP = color.rgb(250, 204, 21)
color COLOR_OPENING_RANGE = color.rgb(245, 158, 11)

color COLOR_PANEL = color.rgb(18, 22, 30)
color COLOR_HEADER = color.rgb(28, 33, 43)


//=============================================================================
// ZONE STORAGE
//
// Arrays must be declared before findZoneIndex().
//=============================================================================

var float[] zoneTops = array.new_float()
var float[] zoneBottoms = array.new_float()

var int[] zoneTypes = array.new_int()
var int[] zoneIds = array.new_int()
var int[] zoneCreatedBars = array.new_int()

var bool[] zoneEvaluated = array.new_bool()

var int nextZoneId = 1


//=============================================================================
// HELPER FUNCTION
//=============================================================================

findZoneIndex(int requestedZoneId) =>
    int result = -1

    if not na(requestedZoneId)
        int zoneCount = array.size(zoneIds)

        if zoneCount > 0
            for index = 0 to zoneCount - 1
                if array.get(zoneIds, index) == requestedZoneId
                    result := index
                    break

    result


//=============================================================================
// UTC DAY
//=============================================================================

string UTC_TIMEZONE = "Etc/UTC"

int utcDateKey = (
     year(time, UTC_TIMEZONE) * 10000 +
     month(time, UTC_TIMEZONE) * 100 +
     dayofmonth(time, UTC_TIMEZONE)
)

int utcMinuteOfDay = (
     hour(time, UTC_TIMEZONE) * 60 +
     minute(time, UTC_TIMEZONE)
)

bool newUtcDay = (
     na(utcDateKey[1]) or
     utcDateKey != utcDateKey[1]
)


//=============================================================================
// ATR
//=============================================================================

float atr = ta.atr(atrLength)


//=============================================================================
// UTC DAILY VWAP
//=============================================================================

var float cumulativePriceVolume = 0.0
var float cumulativeVolume = 0.0

if newUtcDay
    cumulativePriceVolume := 0.0
    cumulativeVolume := 0.0

float currentVolume = nz(volume, 0.0)

cumulativePriceVolume += hlc3 * currentVolume
cumulativeVolume += currentVolume

float dailyVWAP = (
     cumulativeVolume > 0
     ? cumulativePriceVolume / cumulativeVolume
     : na
)

float displayedVWAP = (
     newUtcDay
     ? na
     : dailyVWAP
)


//=============================================================================
// UTC OPENING RANGE
//=============================================================================

var float openingRangeHigh = na
var float openingRangeLow = na

if newUtcDay
    openingRangeHigh := na
    openingRangeLow := na

bool insideOpeningRange = utcMinuteOfDay < openingRangeMinutes
bool openingRangeComplete = utcMinuteOfDay >= openingRangeMinutes

if insideOpeningRange
    openingRangeHigh := (
         na(openingRangeHigh)
         ? high
         : math.max(openingRangeHigh, high)
    )

    openingRangeLow := (
         na(openingRangeLow)
         ? low
         : math.min(openingRangeLow, low)
    )

float displayedOpeningRangeHigh = (
     newUtcDay
     ? na
     : openingRangeHigh
)

float displayedOpeningRangeLow = (
     newUtcDay
     ? na
     : openingRangeLow
)


//=============================================================================
// CONFIRMED PIVOTS
//=============================================================================

float confirmedPivotHigh = ta.pivothigh(
     high,
     pivotLeft,
     pivotRight
)

float confirmedPivotLow = ta.pivotlow(
     low,
     pivotLeft,
     pivotRight
)


//=============================================================================
// CREATE ZONES
//=============================================================================

if barstate.isconfirmed

    if not na(confirmedPivotHigh) and not na(atr[pivotRight])

        float resistanceTop = confirmedPivotHigh

        float resistanceBottom = (
             confirmedPivotHigh -
             atr[pivotRight] * zoneDepthATR
        )

        array.push(zoneTops, resistanceTop)
        array.push(zoneBottoms, resistanceBottom)

        array.push(zoneTypes, ZONE_RESISTANCE)
        array.push(zoneIds, nextZoneId)
        array.push(zoneCreatedBars, bar_index - pivotRight)

        array.push(zoneEvaluated, false)

        nextZoneId += 1

    if not na(confirmedPivotLow) and not na(atr[pivotRight])

        float supportBottom = confirmedPivotLow

        float supportTop = (
             confirmedPivotLow +
             atr[pivotRight] * zoneDepthATR
        )

        array.push(zoneTops, supportTop)
        array.push(zoneBottoms, supportBottom)

        array.push(zoneTypes, ZONE_SUPPORT)
        array.push(zoneIds, nextZoneId)
        array.push(zoneCreatedBars, bar_index - pivotRight)

        array.push(zoneEvaluated, false)

        nextZoneId += 1

    while array.size(zoneIds) > MAX_STORED_ZONES
        array.shift(zoneTops)
        array.shift(zoneBottoms)

        array.shift(zoneTypes)
        array.shift(zoneIds)
        array.shift(zoneCreatedBars)

        array.shift(zoneEvaluated)


//=============================================================================
// REMOVE INVALIDATED ZONES
//=============================================================================

if barstate.isconfirmed and array.size(zoneIds) > 0

    float zoneInvalidationBuffer = atr * invalidationBufferATR
    int removalIndex = array.size(zoneIds) - 1

    while removalIndex >= 0

        int zoneType = array.get(
             zoneTypes,
             removalIndex
        )

        float zoneTop = array.get(
             zoneTops,
             removalIndex
        )

        float zoneBottom = array.get(
             zoneBottoms,
             removalIndex
        )

        bool supportInvalidated = (
             zoneType == ZONE_SUPPORT and
             close < zoneBottom - zoneInvalidationBuffer
        )

        bool resistanceInvalidated = (
             zoneType == ZONE_RESISTANCE and
             close > zoneTop + zoneInvalidationBuffer
        )

        if supportInvalidated or resistanceInvalidated

            array.remove(zoneTops, removalIndex)
            array.remove(zoneBottoms, removalIndex)

            array.remove(zoneTypes, removalIndex)
            array.remove(zoneIds, removalIndex)
            array.remove(zoneCreatedBars, removalIndex)

            array.remove(zoneEvaluated, removalIndex)

        removalIndex -= 1


//=============================================================================
// FIND NEAREST SUPPORT AND RESISTANCE
//=============================================================================

int nearestSupportIndex = -1
int nearestResistanceIndex = -1

float bestSupportDistance = na
float bestResistanceDistance = na

if array.size(zoneIds) > 0

    for index = 0 to array.size(zoneIds) - 1

        int zoneType = array.get(
             zoneTypes,
             index
        )

        float zoneTop = array.get(
             zoneTops,
             index
        )

        float zoneBottom = array.get(
             zoneBottoms,
             index
        )

        if zoneType == ZONE_SUPPORT and close >= zoneBottom

            float supportDistance = (
                 close > zoneTop
                 ? close - zoneTop
                 : 0.0
            )

            if na(bestSupportDistance) or supportDistance < bestSupportDistance
                bestSupportDistance := supportDistance
                nearestSupportIndex := index

        if zoneType == ZONE_RESISTANCE and close <= zoneTop

            float resistanceDistance = (
                 close < zoneBottom
                 ? zoneBottom - close
                 : 0.0
            )

            if na(bestResistanceDistance) or resistanceDistance < bestResistanceDistance
                bestResistanceDistance := resistanceDistance
                nearestResistanceIndex := index


//=============================================================================
// CURRENT ZONE VALUES
//=============================================================================

int nearestSupportId = (
     nearestSupportIndex >= 0
     ? array.get(zoneIds, nearestSupportIndex)
     : na
)

int nearestResistanceId = (
     nearestResistanceIndex >= 0
     ? array.get(zoneIds, nearestResistanceIndex)
     : na
)


float nearestSupportTop = (
     nearestSupportIndex >= 0
     ? array.get(zoneTops, nearestSupportIndex)
     : na
)

float nearestSupportBottom = (
     nearestSupportIndex >= 0
     ? array.get(zoneBottoms, nearestSupportIndex)
     : na
)


float nearestResistanceTop = (
     nearestResistanceIndex >= 0
     ? array.get(zoneTops, nearestResistanceIndex)
     : na
)

float nearestResistanceBottom = (
     nearestResistanceIndex >= 0
     ? array.get(zoneBottoms, nearestResistanceIndex)
     : na
)


bool supportAlreadyEvaluated = (
     nearestSupportIndex >= 0
     ? array.get(zoneEvaluated, nearestSupportIndex)
     : false
)

bool resistanceAlreadyEvaluated = (
     nearestResistanceIndex >= 0
     ? array.get(zoneEvaluated, nearestResistanceIndex)
     : false
)


//=============================================================================
// PRICE LOCATION
//=============================================================================

bool atSupport = (
     nearestSupportIndex >= 0 and
     low <= nearestSupportTop and
     high >= nearestSupportBottom
)

bool atResistance = (
     nearestResistanceIndex >= 0 and
     high >= nearestResistanceBottom and
     low <= nearestResistanceTop
)


//=============================================================================
// COMPRESSED AREA
//=============================================================================

bool hasSupportAndResistance = (
     nearestSupportIndex >= 0 and
     nearestResistanceIndex >= 0
)

float distanceBetweenZones = (
     hasSupportAndResistance
     ? nearestResistanceBottom - nearestSupportTop
     : na
)

float minimumAllowedZoneGap = atr * minimumZoneGapATR

bool zonesCloseTogether = (
     hasSupportAndResistance and
     distanceBetweenZones <= minimumAllowedZoneGap
)


//=============================================================================
// MARKET CONTEXT
//=============================================================================

float neutralVWAPBand = atr * neutralDistanceATR

bool nearVWAP = (
     not na(dailyVWAP) and
     math.abs(close - dailyVWAP) <= neutralVWAPBand
)

bool bullishContext = (
     not nearVWAP and
     not na(dailyVWAP) and
     close > dailyVWAP + neutralVWAPBand
)

bool bearishContext = (
     not nearVWAP and
     not na(dailyVWAP) and
     close < dailyVWAP - neutralVWAPBand
)

bool strongBullishContext = (
     bullishContext and
     openingRangeComplete and
     not na(openingRangeHigh) and
     close > openingRangeHigh
)

bool strongBearishContext = (
     bearishContext and
     openingRangeComplete and
     not na(openingRangeLow) and
     close < openingRangeLow
)


//=============================================================================
// REACTION OBSERVATION
//
// This logic observes reactions only.
// It does not create a trade plan.
//=============================================================================

var int watchState = WATCH_NONE
var int watchedZoneId = na
var int watchStartedBar = na

bool eventSupportObservationStarted = false
bool eventResistanceObservationStarted = false

bool eventSupportReaction = false
bool eventResistanceReaction = false

bool eventContextChanged = false
bool eventZoneInvalidated = false
bool eventWindowExpired = false

bool eventCompressedArea = (
     barstate.isconfirmed and
     zonesCloseTogether and
     not zonesCloseTogether[1]
)

int currentEvent = EVENT_NONE


//=============================================================================
// RESET OBSERVATION
//=============================================================================

if newUtcDay
    watchState := WATCH_NONE
    watchedZoneId := na
    watchStartedBar := na


//=============================================================================
// PROCESS OBSERVATION
//=============================================================================

if barstate.isconfirmed

    currentEvent := EVENT_NONE

    //---------------------------------------------------------------------
    // Observe Support
    //---------------------------------------------------------------------

    if watchState == WATCH_SUPPORT

        int watchedSupportIndex = findZoneIndex(
             watchedZoneId
        )

        int watchAge = (
             not na(watchStartedBar)
             ? bar_index - watchStartedBar
             : reactionWindowBars + 1
        )

        if watchedSupportIndex < 0

            currentEvent := EVENT_ZONE_INVALIDATED
            eventZoneInvalidated := true

            watchState := WATCH_NONE
            watchedZoneId := na
            watchStartedBar := na

        else

            float watchedSupportTop = array.get(
                 zoneTops,
                 watchedSupportIndex
            )

            bool supportReactionDetected = (
                 watchAge >= 1 and
                 close > watchedSupportTop and
                 close > dailyVWAP
            )

            if not bullishContext

                array.set(
                     zoneEvaluated,
                     watchedSupportIndex,
                     true
                )

                currentEvent := EVENT_CONTEXT_CHANGED
                eventContextChanged := true

                watchState := WATCH_NONE
                watchedZoneId := na
                watchStartedBar := na

            else if supportReactionDetected

                array.set(
                     zoneEvaluated,
                     watchedSupportIndex,
                     true
                )

                currentEvent := EVENT_SUPPORT_REACTION
                eventSupportReaction := true

                watchState := WATCH_NONE
                watchedZoneId := na
                watchStartedBar := na

            else if watchAge > reactionWindowBars

                array.set(
                     zoneEvaluated,
                     watchedSupportIndex,
                     true
                )

                currentEvent := EVENT_WINDOW_EXPIRED
                eventWindowExpired := true

                watchState := WATCH_NONE
                watchedZoneId := na
                watchStartedBar := na

    //---------------------------------------------------------------------
    // Observe Resistance
    //---------------------------------------------------------------------

    else if watchState == WATCH_RESISTANCE

        int watchedResistanceIndex = findZoneIndex(
             watchedZoneId
        )

        int watchAge = (
             not na(watchStartedBar)
             ? bar_index - watchStartedBar
             : reactionWindowBars + 1
        )

        if watchedResistanceIndex < 0

            currentEvent := EVENT_ZONE_INVALIDATED
            eventZoneInvalidated := true

            watchState := WATCH_NONE
            watchedZoneId := na
            watchStartedBar := na

        else

            float watchedResistanceBottom = array.get(
                 zoneBottoms,
                 watchedResistanceIndex
            )

            bool resistanceReactionDetected = (
                 watchAge >= 1 and
                 close < watchedResistanceBottom and
                 close < dailyVWAP
            )

            if not bearishContext

                array.set(
                     zoneEvaluated,
                     watchedResistanceIndex,
                     true
                )

                currentEvent := EVENT_CONTEXT_CHANGED
                eventContextChanged := true

                watchState := WATCH_NONE
                watchedZoneId := na
                watchStartedBar := na

            else if resistanceReactionDetected

                array.set(
                     zoneEvaluated,
                     watchedResistanceIndex,
                     true
                )

                currentEvent := EVENT_RESISTANCE_REACTION
                eventResistanceReaction := true

                watchState := WATCH_NONE
                watchedZoneId := na
                watchStartedBar := na

            else if watchAge > reactionWindowBars

                array.set(
                     zoneEvaluated,
                     watchedResistanceIndex,
                     true
                )

                currentEvent := EVENT_WINDOW_EXPIRED
                eventWindowExpired := true

                watchState := WATCH_NONE
                watchedZoneId := na
                watchStartedBar := na

    //---------------------------------------------------------------------
    // Start new observation
    //---------------------------------------------------------------------

    if watchState == WATCH_NONE and currentEvent == EVENT_NONE

        bool canObserveSupport = (
             not zonesCloseTogether and
             bullishContext and
             atSupport and
             nearestSupportIndex >= 0 and
             not supportAlreadyEvaluated
        )

        bool canObserveResistance = (
             not zonesCloseTogether and
             bearishContext and
             atResistance and
             nearestResistanceIndex >= 0 and
             not resistanceAlreadyEvaluated
        )

        if canObserveSupport

            watchState := WATCH_SUPPORT
            watchedZoneId := nearestSupportId
            watchStartedBar := bar_index

            eventSupportObservationStarted := true

        else if canObserveResistance

            watchState := WATCH_RESISTANCE
            watchedZoneId := nearestResistanceId
            watchStartedBar := bar_index

            eventResistanceObservationStarted := true


//=============================================================================
// DASHBOARD SNAPSHOT
//
// Values update only after a candle closes.
//=============================================================================

var string dashboardContext = "Neutral"
var string dashboardLocation = "No Zone"
var string dashboardStatus = "Monitoring Market"

var color dashboardContextColor = COLOR_NEUTRAL
var color dashboardLocationColor = COLOR_NEUTRAL
var color dashboardStatusColor = COLOR_NEUTRAL


if barstate.isconfirmed

    //---------------------------------------------------------------------
    // Context
    //---------------------------------------------------------------------

    if strongBullishContext
        dashboardContext := "Strong Bullish"
        dashboardContextColor := COLOR_BULLISH

    else if strongBearishContext
        dashboardContext := "Strong Bearish"
        dashboardContextColor := COLOR_BEARISH

    else if bullishContext
        dashboardContext := "Bullish"
        dashboardContextColor := COLOR_BULLISH

    else if bearishContext
        dashboardContext := "Bearish"
        dashboardContextColor := COLOR_BEARISH

    else
        dashboardContext := "Neutral"
        dashboardContextColor := COLOR_NEUTRAL

    //---------------------------------------------------------------------
    // Location
    //---------------------------------------------------------------------

    if zonesCloseTogether
        dashboardLocation := "Compressed Area"
        dashboardLocationColor := COLOR_WARNING

    else if atSupport and not atResistance
        dashboardLocation := "At Support"
        dashboardLocationColor := COLOR_BULLISH

    else if atResistance and not atSupport
        dashboardLocation := "At Resistance"
        dashboardLocationColor := COLOR_BEARISH

    else if nearestSupportIndex < 0 and nearestResistanceIndex < 0
        dashboardLocation := "No Zone"
        dashboardLocationColor := COLOR_NEUTRAL

    else
        dashboardLocation := "Between Zones"
        dashboardLocationColor := COLOR_NEUTRAL

    //---------------------------------------------------------------------
    // Status: completed event
    //---------------------------------------------------------------------

    if currentEvent == EVENT_SUPPORT_REACTION
        dashboardStatus := "Support Reaction Detected"
        dashboardStatusColor := COLOR_INFORMATION

    else if currentEvent == EVENT_RESISTANCE_REACTION
        dashboardStatus := "Resistance Reaction Detected"
        dashboardStatusColor := COLOR_INFORMATION

    else if currentEvent == EVENT_CONTEXT_CHANGED
        dashboardStatus := "Context Changed"
        dashboardStatusColor := COLOR_WARNING

    else if currentEvent == EVENT_ZONE_INVALIDATED
        dashboardStatus := "Zone Invalidated"
        dashboardStatusColor := COLOR_WARNING

    else if currentEvent == EVENT_WINDOW_EXPIRED
        dashboardStatus := "Reaction Window Expired"
        dashboardStatusColor := COLOR_WARNING

    //---------------------------------------------------------------------
    // Status: observation in progress
    //---------------------------------------------------------------------

    else if watchState == WATCH_SUPPORT
        dashboardStatus := "Observing Support Reaction"
        dashboardStatusColor := COLOR_INFORMATION

    else if watchState == WATCH_RESISTANCE
        dashboardStatus := "Observing Resistance Reaction"
        dashboardStatusColor := COLOR_INFORMATION

    //---------------------------------------------------------------------
    // Status: current structure
    //---------------------------------------------------------------------

    else if zonesCloseTogether
        dashboardStatus := "Zones Close Together"
        dashboardStatusColor := COLOR_WARNING

    else if bullishContext and atResistance
        dashboardStatus := "Bullish Context at Resistance"
        dashboardStatusColor := COLOR_WARNING

    else if bearishContext and atSupport
        dashboardStatus := "Bearish Context at Support"
        dashboardStatusColor := COLOR_WARNING

    else if bullishContext and atSupport and supportAlreadyEvaluated
        dashboardStatus := "Support Already Evaluated"
        dashboardStatusColor := COLOR_NEUTRAL

    else if bearishContext and atResistance and resistanceAlreadyEvaluated
        dashboardStatus := "Resistance Already Evaluated"
        dashboardStatusColor := COLOR_NEUTRAL

    else if bullishContext
        dashboardStatus := "Monitoring Support"
        dashboardStatusColor := COLOR_NEUTRAL

    else if bearishContext
        dashboardStatus := "Monitoring Resistance"
        dashboardStatusColor := COLOR_NEUTRAL

    else
        dashboardStatus := "Monitoring Market"
        dashboardStatusColor := COLOR_NEUTRAL


//=============================================================================
// VWAP AND OPENING RANGE
//=============================================================================

vwapPlot = plot(
     showVWAP ? displayedVWAP : na,
     title = "UTC Daily VWAP",
     color = COLOR_VWAP,
     linewidth = 2,
     style = plot.style_linebr
)

openingRangeHighPlot = plot(
     showOpeningRange ? displayedOpeningRangeHigh : na,
     title = "Opening Range High",
     color = color.new(COLOR_OPENING_RANGE, 25),
     linewidth = 1,
     style = plot.style_linebr
)

openingRangeLowPlot = plot(
     showOpeningRange ? displayedOpeningRangeLow : na,
     title = "Opening Range Low",
     color = color.new(COLOR_OPENING_RANGE, 25),
     linewidth = 1,
     style = plot.style_linebr
)

fill(
     openingRangeHighPlot,
     openingRangeLowPlot,
     color = showOpeningRange
          ? color.new(COLOR_OPENING_RANGE, 96)
          : na,
     title = "Opening Range"
)


//=============================================================================
// ZONE VISUAL OBJECTS
//=============================================================================

var box supportBox = na
var box resistanceBox = na

var label supportLabel = na
var label resistanceLabel = na

var int displayedSupportId = na
var int displayedResistanceId = na


bool supportObservationActive = (
     watchState == WATCH_SUPPORT and
     watchedZoneId == nearestSupportId
)

bool resistanceObservationActive = (
     watchState == WATCH_RESISTANCE and
     watchedZoneId == nearestResistanceId
)


//=============================================================================
// SUPPORT VISUAL
//=============================================================================

if showZones and nearestSupportIndex >= 0

    int supportCreatedBar = array.get(
         zoneCreatedBars,
         nearestSupportIndex
    )

    int supportLeft = math.max(
         supportCreatedBar,
         bar_index - 5000
    )

    color supportFill = color.new(
         COLOR_BULLISH,
         supportObservationActive ? 78 : 88
    )

    color supportBorder = color.new(
         COLOR_BULLISH,
         supportObservationActive ? 10 : 45
    )

    bool createNewSupportBox = (
         na(supportBox) or
         displayedSupportId != nearestSupportId
    )

    if createNewSupportBox

        if not na(supportBox)
            box.delete(supportBox)

        if not na(supportLabel)
            label.delete(supportLabel)

        supportBox := box.new(
             left = supportLeft,
             top = nearestSupportTop,
             right = bar_index + ZONE_FORWARD_BARS,
             bottom = nearestSupportBottom,
             xloc = xloc.bar_index,
             bgcolor = supportFill,
             border_color = supportBorder
        )

        supportLabel := label.new(
             x = bar_index + ZONE_LABEL_FORWARD_BARS,
             y = (nearestSupportTop + nearestSupportBottom) * 0.5,
             text = "Support",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             size = size.tiny,
             color = color.new(COLOR_BULLISH, 70),
             textcolor = color.white
        )

        displayedSupportId := nearestSupportId

    else

        box.set_left(
             supportBox,
             supportLeft
        )

        box.set_right(
             supportBox,
             bar_index + ZONE_FORWARD_BARS
        )

        box.set_top(
             supportBox,
             nearestSupportTop
        )

        box.set_bottom(
             supportBox,
             nearestSupportBottom
        )

        box.set_bgcolor(
             supportBox,
             supportFill
        )

        box.set_border_color(
             supportBox,
             supportBorder
        )

        label.set_xy(
             supportLabel,
             bar_index + ZONE_LABEL_FORWARD_BARS,
             (nearestSupportTop + nearestSupportBottom) * 0.5
        )

else

    if not na(supportBox)
        box.delete(supportBox)
        supportBox := na

    if not na(supportLabel)
        label.delete(supportLabel)
        supportLabel := na

    displayedSupportId := na


//=============================================================================
// RESISTANCE VISUAL
//=============================================================================

if showZones and nearestResistanceIndex >= 0

    int resistanceCreatedBar = array.get(
         zoneCreatedBars,
         nearestResistanceIndex
    )

    int resistanceLeft = math.max(
         resistanceCreatedBar,
         bar_index - 5000
    )

    color resistanceFill = color.new(
         COLOR_BEARISH,
         resistanceObservationActive ? 78 : 88
    )

    color resistanceBorder = color.new(
         COLOR_BEARISH,
         resistanceObservationActive ? 10 : 45
    )

    bool createNewResistanceBox = (
         na(resistanceBox) or
         displayedResistanceId != nearestResistanceId
    )

    if createNewResistanceBox

        if not na(resistanceBox)
            box.delete(resistanceBox)

        if not na(resistanceLabel)
            label.delete(resistanceLabel)

        resistanceBox := box.new(
             left = resistanceLeft,
             top = nearestResistanceTop,
             right = bar_index + ZONE_FORWARD_BARS,
             bottom = nearestResistanceBottom,
             xloc = xloc.bar_index,
             bgcolor = resistanceFill,
             border_color = resistanceBorder
        )

        resistanceLabel := label.new(
             x = bar_index + ZONE_LABEL_FORWARD_BARS + 2,
             y = (nearestResistanceTop + nearestResistanceBottom) * 0.5,
             text = "Resistance",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             size = size.tiny,
             color = color.new(COLOR_BEARISH, 70),
             textcolor = color.white
        )

        displayedResistanceId := nearestResistanceId

    else

        box.set_left(
             resistanceBox,
             resistanceLeft
        )

        box.set_right(
             resistanceBox,
             bar_index + ZONE_FORWARD_BARS
        )

        box.set_top(
             resistanceBox,
             nearestResistanceTop
        )

        box.set_bottom(
             resistanceBox,
             nearestResistanceBottom
        )

        box.set_bgcolor(
             resistanceBox,
             resistanceFill
        )

        box.set_border_color(
             resistanceBox,
             resistanceBorder
        )

        label.set_xy(
             resistanceLabel,
             bar_index + ZONE_LABEL_FORWARD_BARS + 2,
             (nearestResistanceTop + nearestResistanceBottom) * 0.5
        )

else

    if not na(resistanceBox)
        box.delete(resistanceBox)
        resistanceBox := na

    if not na(resistanceLabel)
        label.delete(resistanceLabel)
        resistanceLabel := na

    displayedResistanceId := na


//=============================================================================
// DASHBOARD
//=============================================================================

float chartTimeframeSeconds = timeframe.in_seconds()

bool recommendedTimeframe = (
     timeframe.isintraday and
     chartTimeframeSeconds >= 180 and
     chartTimeframeSeconds <= 900
)

bool cryptoSymbol = syminfo.type == "crypto"

var table dashboard = table.new(
     position.top_right,
     2,
     4,
     border_width = 1
)

if barstate.islast

    table.clear(
         dashboard,
         0,
         0,
         1,
         3
    )

    if showDashboard

        string headerNote = "Structure View"
        color headerNoteColor = COLOR_NEUTRAL

        if not cryptoSymbol
            headerNote := "Crypto Only"
            headerNoteColor := COLOR_WARNING

        else if not recommendedTimeframe
            headerNote := "TF 3-15m"
            headerNoteColor := COLOR_WARNING

        table.cell(
             dashboard,
             0,
             0,
             "Crypto Intraday Engine",
             text_color = color.white,
             bgcolor = COLOR_HEADER,
             text_size = size.small
        )

        table.cell(
             dashboard,
             1,
             0,
             headerNote,
             text_color = headerNoteColor,
             bgcolor = COLOR_HEADER,
             text_size = size.small
        )

        table.cell(
             dashboard,
             0,
             1,
             "Context",
             text_color = color.white,
             bgcolor = COLOR_PANEL,
             text_size = size.small
        )

        table.cell(
             dashboard,
             1,
             1,
             dashboardContext,
             text_color = dashboardContextColor,
             bgcolor = COLOR_PANEL,
             text_size = size.small
        )

        table.cell(
             dashboard,
             0,
             2,
             "Location",
             text_color = color.white,
             bgcolor = COLOR_PANEL,
             text_size = size.small
        )

        table.cell(
             dashboard,
             1,
             2,
             dashboardLocation,
             text_color = dashboardLocationColor,
             bgcolor = COLOR_PANEL,
             text_size = size.small
        )

        table.cell(
             dashboard,
             0,
             3,
             "Status",
             text_color = color.white,
             bgcolor = COLOR_PANEL,
             text_size = size.small
        )

        table.cell(
             dashboard,
             1,
             3,
             dashboardStatus,
             text_color = dashboardStatusColor,
             bgcolor = COLOR_PANEL,
             text_size = size.small
        )


//=============================================================================
// INFORMATIONAL ALERTS
//=============================================================================

alertcondition(
     eventSupportObservationStarted,
     "Support Observation Started",
     "Crypto Intraday Engine: price reached a Support zone."
)

alertcondition(
     eventResistanceObservationStarted,
     "Resistance Observation Started",
     "Crypto Intraday Engine: price reached a Resistance zone."
)

alertcondition(
     eventSupportReaction,
     "Support Reaction Detected",
     "Crypto Intraday Engine: a reaction from Support was detected."
)

alertcondition(
     eventResistanceReaction,
     "Resistance Reaction Detected",
     "Crypto Intraday Engine: a reaction from Resistance was detected."
)

alertcondition(
     eventContextChanged,
     "Context Changed",
     "Crypto Intraday Engine: market context changed during zone observation."
)

alertcondition(
     eventZoneInvalidated,
     "Zone Invalidated",
     "Crypto Intraday Engine: the observed zone was invalidated."
)

alertcondition(
     eventWindowExpired,
     "Reaction Window Expired",
     "Crypto Intraday Engine: the observation window expired."
)

alertcondition(
     eventCompressedArea,
     "Zones Close Together",
     "Crypto Intraday Engine: Support and Resistance are located close together."
)
````
