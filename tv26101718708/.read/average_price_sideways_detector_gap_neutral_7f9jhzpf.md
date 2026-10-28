# Average Price Sideways Detector - Gap Neutral

- url: https://www.tradingview.com/script/7f9jHZPf-Average-Price-Sideways-Detector-Gap-Neutral/
- type: indicator
- pine_id: PUB;9b6476ed455c430eaf5eed0936d81da0
- version: 1.0

## Description

## Average Price Sideways Detector – Gap Neutral

The **Average Price Sideways Detector (APSD)** is designed to identify bullish, bearish, and sideways market conditions by analyzing the behavior of the average price derived from each candle's **High, Low, and Close (HLC3)**.

Unlike conventional trend indicators, APSD focuses on **average-price direction, price compression, and persistence** to identify periods where the market is genuinely moving sideways.

### How It Works

For every candle, the indicator calculates the typical price:

**Typical Price = (High + Low + Close) / 3**

It then analyzes three primary characteristics:

**Average Price Slope:** Measures the directional movement of the average price. A nearly flat slope indicates a potential sideways market.

**Price Compression:** Measures how tightly recent average prices are grouped. Lower compression ranges indicate consolidation and reduced directional movement.

**Sideways Persistence:** A sideways condition must remain valid for a specified number of consecutive candles before it is confirmed. This helps reduce temporary and false sideways signals.

### Gap-Neutral Calculation

The indicator resets its internal price calculation at the beginning of each new trading day. Therefore, overnight **gap-ups and gap-downs do not directly distort the current session's sideways analysis**.

This feature is particularly useful for intraday markets where significant opening gaps can otherwise influence rolling indicators for several candles.

### Indicator Interpretation

🟢 **Green Line** – Bullish price momentum

🔴 **Red Line** – Bearish price momentum

⚪ **Gray Line** – Neutral or sideways market condition

When a sideways market is fully confirmed through both flatness and compression conditions, the oscillator moves to the **zero line**.

The upper and lower threshold levels help separate meaningful directional movement from the neutral zone.

### Key Features

* Based primarily on High, Low, and Close average-price behavior
* Identifies price compression and average-price flatness
* Confirms sideways conditions using consecutive candles
* Gap-neutral session-based calculation
* Separates bullish, bearish, and sideways market conditions
* Adjustable sensitivity and confirmation settings
* Designed primarily for intraday market analysis

### Important Note

The indicator should be used as a market-condition detection tool rather than as a standalone buy or sell signal. Settings may need adjustment depending on the instrument, timeframe, and prevailing market volatility.

**Developed by Firozstar**

## Source Code

````pine
//@version=6
indicator(
     title = "Average Price Sideways Detector - Gap Neutral",
     shorttitle = "APSD Gap Neutral",
     overlay = false
)

//────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────
averageLength = input.int(
     20,
     "Average Length",
     minval = 2
)

slopeBars = input.int(
     5,
     "Slope Lookback",
     minval = 1
)

smoothLength = input.int(
     5,
     "Momentum Smoothing",
     minval = 1
)

minimumSessionBars = input.int(
     5,
     "Minimum Bars After Session Open",
     minval = 1
)

slopeThreshold = input.float(
     0.08,
     "Maximum Slope for Sideways (%)",
     step = 0.01
)

compressionThreshold = input.float(
     0.35,
     "Maximum Compression Range (%)",
     step = 0.01
)

confirmBars = input.int(
     3,
     "Sideways Confirmation Bars",
     minval = 1
)

upperLevel = input.float(
     0.15,
     "Bullish Level",
     step = 0.01
)

lowerLevel = input.float(
     -0.15,
     "Bearish Level",
     step = 0.01
)

//────────────────────────────────────────────
// Detect new trading day
//────────────────────────────────────────────
newDay = ta.change(time("D")) != 0

//────────────────────────────────────────────
// Count bars from session start
//────────────────────────────────────────────
var int sessionBarCount = 0

if newDay
    sessionBarCount := 1
else
    sessionBarCount += 1

//────────────────────────────────────────────
// Typical Price
//────────────────────────────────────────────
typicalPrice = (high + low + close) / 3.0

//────────────────────────────────────────────
// Session based arrays
//
// These prevent previous day's prices from
// affecting today's calculations.
//────────────────────────────────────────────
var float[] sessionPrices = array.new_float()

if newDay
    array.clear(sessionPrices)

array.push(sessionPrices, typicalPrice)

// Keep only required bars
if array.size(sessionPrices) > averageLength
    array.shift(sessionPrices)

//────────────────────────────────────────────
// Session Average
//────────────────────────────────────────────
float sessionAverage = na
float sessionHighest = na
float sessionLowest = na

if array.size(sessionPrices) > 0
    float sumPrice = 0.0
    float maxPrice = array.get(sessionPrices, 0)
    float minPrice = array.get(sessionPrices, 0)

    for i = 0 to array.size(sessionPrices) - 1
        value = array.get(sessionPrices, i)

        sumPrice += value
        maxPrice := math.max(maxPrice, value)
        minPrice := math.min(minPrice, value)

    sessionAverage := sumPrice / array.size(sessionPrices)
    sessionHighest := maxPrice
    sessionLowest := minPrice

//────────────────────────────────────────────
// Smooth session average
//────────────────────────────────────────────
smoothedAverage = ta.ema(sessionAverage, smoothLength)

//────────────────────────────────────────────
// Slope calculation
//
// Only calculated after enough bars exist
// inside the current session.
//────────────────────────────────────────────
validSlope =
     sessionBarCount > slopeBars

slopePercent =
     validSlope and not na(smoothedAverage[slopeBars])
     ? (
         (smoothedAverage - smoothedAverage[slopeBars])
         / smoothedAverage[slopeBars]
       ) * 100
     : na

//────────────────────────────────────────────
// Compression calculation
//────────────────────────────────────────────
sessionRange =
     sessionHighest - sessionLowest

compressionPercent =
     sessionAverage != 0
     ? (sessionRange / sessionAverage) * 100
     : na

//────────────────────────────────────────────
// Directional momentum
//────────────────────────────────────────────
rawMomentum =
     sessionRange != 0
     ? (typicalPrice - sessionAverage)
       / sessionRange
     : 0

momentum =
     ta.ema(rawMomentum, smoothLength)

//────────────────────────────────────────────
// Sideways conditions
//────────────────────────────────────────────
flatAverage =
     not na(slopePercent)
     and math.abs(slopePercent) <= slopeThreshold

compressedMarket =
     not na(compressionPercent)
     and compressionPercent <= compressionThreshold

enoughSessionBars =
     sessionBarCount >= minimumSessionBars

sidewaysRaw =
     enoughSessionBars
     and flatAverage
     and compressedMarket

//────────────────────────────────────────────
// Consecutive sideways confirmation
//────────────────────────────────────────────
var int sidewaysCount = 0

if newDay
    sidewaysCount := 0
else
    if sidewaysRaw
        sidewaysCount += 1
    else
        sidewaysCount := 0

sidewaysConfirmed =
     sidewaysCount >= confirmBars

//────────────────────────────────────────────
// Final State
//
//  1 = Bullish
//  0 = Sideways / Neutral
// -1 = Bearish
//────────────────────────────────────────────
state =
     sidewaysConfirmed
     ? 0
     : momentum > upperLevel
     ? 1
     : momentum < lowerLevel
     ? -1
     : 0

//────────────────────────────────────────────
// Final oscillator value
//────────────────────────────────────────────
finalValue =
     sidewaysConfirmed
     ? 0
     : momentum

//────────────────────────────────────────────
// Plot color
//────────────────────────────────────────────
plotColor =
     state == 1
     ? color.green
     : state == -1
     ? color.red
     : color.gray

//────────────────────────────────────────────
// Main plot
//────────────────────────────────────────────
plot(
     finalValue,
     title = "Gap Neutral Sideways Momentum",
     color = plotColor,
     linewidth = 3
)

//────────────────────────────────────────────
// Threshold lines
//────────────────────────────────────────────
hline(
     upperLevel,
     "Bullish Threshold",
     color = color.green,
     linestyle = hline.style_dashed
)

hline(
     0,
     "Sideways Center",
     color = color.gray,
     linestyle = hline.style_dotted
)

hline(
     lowerLevel,
     "Bearish Threshold",
     color = color.red,
     linestyle = hline.style_dashed
)
````
