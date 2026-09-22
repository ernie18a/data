<!-- tradingview-pine-id: PUB;845ee226fb83476f82896f213f019784 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Delta Pressure - Rolling LTF

Source: https://www.tradingview.com/script/X1bfnBiX-Delta-Pressure-Rolling-LTF/

## Description

# Delta Pressure - Rolling LTF

Delta Pressure - Rolling LTF is an intraday volume-pressure indicator designed to show the short-term balance between buying and selling pressure.

It uses lower-timeframe price movement and volume to estimate directional pressure. Lower-timeframe volume is classified as positive when price closes higher, negative when price closes lower, and neutral when price is unchanged. This directional volume is then aggregated into rolling 5-minute flow periods and normalized by total volume to produce a pressure reading.

The indicator is designed primarily for use on a **5-minute chart with the default 1-minute lower timeframe**.

## What It Shows

### Positive Pressure

Values above the zero line indicate that calculated buying pressure is greater than selling pressure during the rolling measurement period.

* **Bright green:** buying pressure is strengthening.
* **Faded green:** buying pressure remains positive but is weakening.
* **Green above zero:** positive buying pressure.

### Negative Pressure

Values below the zero line indicate that calculated selling pressure is greater than buying pressure.

* **Bright red:** selling pressure is strengthening.
* **Faded red:** selling pressure remains negative but is weakening.
* **Red below zero:** negative selling pressure.

### No-Trade Zone

The default No-Trade Zone extends from **-15 to +15**.

This area highlights relatively weak directional pressure. Readings outside the zone represent stronger calculated pressure and can be used to distinguish stronger flow from periods of relatively balanced or weak flow.

The threshold is fully configurable.

## How to Use

The indicator is intended primarily as a **market-pressure and confirmation tool**, rather than as a standalone trading system.

On a 5-minute chart, the default settings are:

* **Lower Timeframe:** 1 minute
* **Flow Window:** 4
* **Smoothing:** 3
* **No-Trade Threshold:** 15

### Bullish Pressure

A trader can watch for situations where:

1. Pressure moves above zero.
2. Buying pressure continues to strengthen.
3. Pressure moves above the +15 threshold.
4. Positive pressure remains strong while price continues its move.

These conditions can be compared with price structure, trend direction, moving averages, support/resistance, or other market analysis.

### Bearish Pressure

A trader can watch for situations where:

1. Pressure moves below zero.
2. Selling pressure continues to strengthen.
3. Pressure moves below the -15 threshold.
4. Negative pressure remains strong while price continues its move.

These conditions can similarly be compared with the broader market structure and other technical indicators.

### Weakening Pressure

The indicator can also be used to identify when existing pressure is losing strength.

For example:

* Positive pressure remains above zero but begins declining.
* Negative pressure remains below zero but begins rising toward zero.

This can provide additional information when evaluating whether an existing move is losing momentum.

## Flow Window

The **Flow Window** controls how many completed 5-minute flow periods are retained in the rolling calculation.

The default value of **4** provides approximately four 5-minute periods of rolling flow while also incorporating the currently developing 5-minute period.

A larger Flow Window produces a slower and more persistent pressure reading.

A smaller Flow Window produces a faster and more responsive pressure reading.

## Alerts

The indicator includes alerts for:

* **Delta Pressure Turns Positive**
* **Delta Pressure Turns Negative**
* **Selling Pressure Recovering**
* **Buying Pressure Weakening**
* **Delta Pressure Above +15**
* **Delta Pressure Below -15**

These alerts can be used to monitor changes in pressure without continuously watching the indicator.

## Important Information

Delta Pressure - Rolling LTF is an **estimated directional pressure calculation**. It does not use actual bid/ask trade classification and therefore should not be interpreted as true bid/ask delta or footprint delta.

The calculation is based on lower-timeframe price movement and volume supplied by TradingView's data feed.

The default configuration is intended for **5-minute intraday analysis**, but the settings can be adjusted for other chart timeframes and instruments where appropriate.

The indicator is designed to provide additional information about current and recent market pressure. It does not predict future price movement and should not be considered a standalone trading system or a guarantee of trading results.

---

## Source Code

````pine
//@version=6
indicator("Delta Pressure - Rolling LTF", shorttitle="Delta Pressure", overlay=false)

// Author: Kerbox
// Delta Pressure - Rolling LTF
//
// Estimates short-term directional pressure using
// lower-timeframe price movement weighted by volume.
//
// The calculation aggregates lower-timeframe data
// into rolling 5-minute flow buckets and normalizes
// directional delta by total volume.
//
// This is an estimated pressure calculation and is
// not true bid/ask order-flow delta.

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

groupFlow = "Flow"
lowerTF = input.timeframe("1", "Lower Timeframe", group=groupFlow)
windowBars = input.int(4, "Flow Window (5M Bars)", minval=1, maxval=20, group=groupFlow)
smoothLength = input.int(3, "Smoothing", minval=1, maxval=10, group=groupFlow)

groupZone = "No-Trade Zone"
showNoTradeZone = input.bool(true, "Show No-Trade Zone", group=groupZone)
noTradeLevel = input.float(15.0, "No-Trade Threshold", minval=1.0, maxval=50.0, step=1.0, group=groupZone)
showZoneFill = input.bool(true, "Show Zone Fill", group=groupZone)
noTradeZoneColor = input.color(color.gray, "No-Trade Zone Color", group=groupZone)

groupDisplay = "Display"
showZero = input.bool(true, "Show Zero Line", group=groupDisplay)
showWeakening = input.bool(true, "Show Weakening Pressure", group=groupDisplay)


// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

int flowTFMillis = 5 * 60 * 1000
string chicagoTZ = "America/Chicago"


// ─────────────────────────────────────────────────────────────────────────────
// CME GLOBEX SESSION
// ─────────────────────────────────────────────────────────────────────────────

f_inSession(int t) =>
    int h = hour(t, chicagoTZ)
    h >= 17 or h < 16

bool inSession = not na(time(timeframe.period, "1700-1600:1234567", chicagoTZ))
bool sessionStart = inSession and not inSession[1]


// ─────────────────────────────────────────────────────────────────────────────
// LOWER-TIMEFRAME DATA
// ─────────────────────────────────────────────────────────────────────────────

array<float> ltfDelta = request.security_lower_tf(
    syminfo.tickerid,
    lowerTF,
    close > close[1] ? volume : close < close[1] ? -volume : 0.0
)

array<float> ltfVolume = request.security_lower_tf(
    syminfo.tickerid,
    lowerTF,
    volume
)

array<int> ltfTime = request.security_lower_tf(
    syminfo.tickerid,
    lowerTF,
    time
)


// ─────────────────────────────────────────────────────────────────────────────
// ROLLING 5-MINUTE FLOW
// ─────────────────────────────────────────────────────────────────────────────

var array<float> deltaWindow = array.new_float()
var array<float> volumeWindow = array.new_float()

var float rollingDelta = 0.0
var float rollingVolume = 0.0

var int currentBucket = na
var float currentBucketDelta = 0.0
var float currentBucketVolume = 0.0


// ─────────────────────────────────────────────────────────────────────────────
// SESSION RESET
// ─────────────────────────────────────────────────────────────────────────────

if sessionStart
    array.clear(deltaWindow)
    array.clear(volumeWindow)

    rollingDelta := 0.0
    rollingVolume := 0.0

    currentBucket := na
    currentBucketDelta := 0.0
    currentBucketVolume := 0.0


// ─────────────────────────────────────────────────────────────────────────────
// BUILD 5-MINUTE BUCKETS
// ─────────────────────────────────────────────────────────────────────────────

int intrabarCount = array.size(ltfDelta)

if intrabarCount > 0
    for i = 0 to intrabarCount - 1
        int t = array.get(ltfTime, i)
        float d = array.get(ltfDelta, i)
        float v = array.get(ltfVolume, i)

        if f_inSession(t)
            int bucket = int(math.floor(float(t) / float(flowTFMillis))) * flowTFMillis

            if na(currentBucket)
                currentBucket := bucket
                currentBucketDelta := d
                currentBucketVolume := v

            else if bucket == currentBucket
                currentBucketDelta += d
                currentBucketVolume += v

            else if bucket > currentBucket
                array.push(deltaWindow, currentBucketDelta)
                array.push(volumeWindow, currentBucketVolume)

                rollingDelta += currentBucketDelta
                rollingVolume += currentBucketVolume

                int completedBucketsToKeep = math.max(windowBars - 1, 0)

                while array.size(deltaWindow) > completedBucketsToKeep
                    float oldDelta = array.shift(deltaWindow)
                    float oldVolume = array.shift(volumeWindow)

                    rollingDelta -= oldDelta
                    rollingVolume -= oldVolume

                currentBucket := bucket
                currentBucketDelta := d
                currentBucketVolume := v


// ─────────────────────────────────────────────────────────────────────────────
// EFFECTIVE ROLLING FLOW
// ─────────────────────────────────────────────────────────────────────────────

float effectiveDelta = rollingDelta + currentBucketDelta
float effectiveVolume = rollingVolume + currentBucketVolume


// ─────────────────────────────────────────────────────────────────────────────
// NORMALIZED PRESSURE
// ─────────────────────────────────────────────────────────────────────────────

float pressureRaw = 0.0

if inSession and effectiveVolume > 0
    pressureRaw := effectiveDelta / effectiveVolume * 100.0

float pressure = ta.ema(pressureRaw, smoothLength)


// ─────────────────────────────────────────────────────────────────────────────
// PRESSURE STATES
// ─────────────────────────────────────────────────────────────────────────────

bool buying = pressure > 0
bool selling = pressure < 0

bool buyingStrengthening = buying and pressure > pressure[1]
bool buyingWeakening = buying and pressure < pressure[1]

bool sellingStrengthening = selling and pressure < pressure[1]
bool sellingWeakening = selling and pressure > pressure[1]


// ─────────────────────────────────────────────────────────────────────────────
// HISTOGRAM
// ─────────────────────────────────────────────────────────────────────────────

color pressureColor = color.gray

if buyingStrengthening
    pressureColor := color.green
else if buyingWeakening and showWeakening
    pressureColor := color.new(color.green, 60)
else if sellingStrengthening
    pressureColor := color.red
else if sellingWeakening and showWeakening
    pressureColor := color.new(color.red, 60)
else if buying
    pressureColor := color.green
else if selling
    pressureColor := color.red

plot(
    inSession ? pressure : na,
    title="Delta Pressure",
    style=plot.style_columns,
    color=pressureColor
)


// ─────────────────────────────────────────────────────────────────────────────
// ZERO LINE
// ─────────────────────────────────────────────────────────────────────────────

hline(
    0,
    "Zero",
    color=showZero ? color.gray : color.new(color.gray, 100)
)


// ─────────────────────────────────────────────────────────────────────────────
// NO-TRADE ZONE
// ─────────────────────────────────────────────────────────────────────────────

float upperZone = showNoTradeZone ? noTradeLevel : na
float lowerZone = showNoTradeZone ? -noTradeLevel : na

upperPlot = plot(
    upperZone,
    title="No-Trade Upper",
    color=color.new(color.gray, 70),
    linewidth=1
)

lowerPlot = plot(
    lowerZone,
    title="No-Trade Lower",
    color=color.new(color.gray, 70),
    linewidth=1
)

fill(
    upperPlot,
    lowerPlot,
    color=showZoneFill ? color.new(noTradeZoneColor, 92) : color.new(noTradeZoneColor, 100),
    title="No-Trade Zone",
    editable=false
)
// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

bool bullishTurn = ta.crossover(pressure, 0)
bool bearishTurn = ta.crossunder(pressure, 0)

bool bullishRecovery = pressure < 0 and pressure > pressure[1] and pressure[1] > pressure[2]
bool bearishRecovery = pressure > 0 and pressure < pressure[1] and pressure[1] < pressure[2]

bool bullishStrong = ta.crossover(pressure, noTradeLevel)
bool bearishStrong = ta.crossunder(pressure, -noTradeLevel)

alertcondition(
    bullishTurn,
    title="Delta Pressure Turns Positive",
    message="Rolling Delta Pressure turned positive."
)

alertcondition(
    bearishTurn,
    title="Delta Pressure Turns Negative",
    message="Rolling Delta Pressure turned negative."
)

alertcondition(
    bullishRecovery,
    title="Selling Pressure Recovering",
    message="Rolling selling pressure is weakening."
)

alertcondition(
    bearishRecovery,
    title="Buying Pressure Weakening",
    message="Buying pressure is weakening."
)

alertcondition(
    bullishStrong,
    title="Delta Pressure Above +15",
    message="Delta Pressure crossed above +15 - meaningful bullish pressure."
)

alertcondition(
    bearishStrong,
    title="Delta Pressure Below -15",
    message="Delta Pressure crossed below -15 - meaningful bearish pressure."
)
````
