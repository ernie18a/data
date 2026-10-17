# Price vs Volume Slope Oscillator + Divergences

- url: https://www.tradingview.com/script/VAKWwuAI-Price-vs-Volume-Slope-Oscillator-Divergences/
- type: indicator
- pine_id: PUB;fc42583a5ead4becb75f37dee18a5b9e
- version: 1.0

## Description

Price–Volume Slopes + Participation Oscillator

Price–Volume Slopes compares the normalized slope of Price with the normalized slope of Volume to show whether market participation is supporting or contradicting the current trend.

Instead of simply asking "Is volume increasing?", this indicator asks:

Is price moving faster than participation, or is participation driving price?

This helps identify:

Healthy trends
Weakening trends
Efficient institutional moves
Capitulation
Distribution
Accumulation
Price–Volume divergences
Main Features
📈 Normalized Price Slope

Measures the momentum of a moving average of price.

Default:

EMA 20
📊 Normalized Volume Slope

Measures the momentum of a moving average of volume.

Default:

EMA 20

Using the same lookback length for both creates a fair comparison between price and participation.

📉 Price − Volume Oscillator (optional)

The difference between normalized price slope and normalized volume slope.

Positive values:

Price is leading participation.

Negative values:

Participation is leading price.

The histogram and signal line are disabled by default to keep the chart clean and can be enabled whenever additional confirmation is needed.

Participation Regimes
🟢 Strong Bull Begins (SB)

Price slope ↑
Volume slope ↑

A healthy bullish trend supported by increasing participation.

🟢 Efficient Bull Begins (EB)

Price slope ↑
Volume slope ↓

Price continues higher despite declining participation.

This often indicates an efficient trend driven by stronger buyers, but prolonged moves can eventually become exhausted.

🔴 Strong Bear Begins (SBr)

Price slope ↓
Volume slope ↑

A healthy bearish trend supported by increasing selling participation.

🟠 Capitulation Begins (CAP)

Large negative price slope with exceptionally strong volume.

May represent:

Panic selling
Liquidations
Bearish continuation
Potential selling climax

Confirmation from price action is recommended.

🟣 Distribution (DIST)

Flat price
High volume

Large trading activity without meaningful price progress.

Often associated with absorption or distribution.

🔵 Accumulation (ACC)

Flat price
Low volume

Quiet market with little directional commitment.

May precede a larger move but should not be treated as a signal by itself.

Pivot Price–Volume Signals

The indicator also detects four confirmed pivot relationships.

Signals are plotted only after the selected number of confirmation candles.

🟣 BW — Bearish Weakening

P↑ V↓

Price makes a Higher High while volume makes a Lower High.

Buyers are pushing price higher with less participation.

Potential bearish warning.

🟢 BuW — Bullish Weakening

P↓ V↓

Price makes a Lower Low while volume makes a Lower Low.

Selling pressure is weakening.

Potential bullish warning.

🔴 BC — Buying Climax

P↑ V↑

Price makes a Higher High while volume also increases.

May indicate:

Strong bullish continuation
Buying climax
Distribution near a top

Requires price confirmation.

🟢 SC — Selling Climax

P↓ V↑

Price makes a Lower Low while volume increases.

May indicate:

Strong bearish continuation
Panic selling
Selling climax
Institutional absorption

Requires price confirmation.

Tooltips

Every regime marker and every pivot signal includes a tooltip explaining:

Signal name
Price behaviour
Volume behaviour
Market interpretation
Typical confirmation
Best Used With
Market Structure (BOS / CHoCH)
Liquidity Sweeps
Wyckoff Springs & Upthrusts
Fair Value Gaps (FVG)
RSI or MACD Divergences
Support & Resistance
Order Blocks

The highest-probability setups occur when multiple forms of confirmation align.

Notes

This indicator measures participation, not prediction.

Strong participation supports trends.

Weak participation often warns that trends are losing conviction.

Volume climaxes identify areas where large market activity is occurring but do not automatically signal reversals.

Always combine Price–Volume analysis with price structure and confirmation before making trading decisions.

## Source Code

````pine
//@version=6
indicator(
     "Price vs Volume Slope Oscillator + Divergences",
     shorttitle = "Price–Volume Slopes",
     overlay = false,
     max_labels_count = 500,
     max_lines_count = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_safe_div(float numerator, float denominator) =>
    not na(denominator) and denominator != 0.0 ? numerator / denominator : 0.0

f_ma(float source, int length, string maType) =>
    maType == "EMA" ? ta.ema(source, length) : ta.sma(source, length)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore = "Core Calculation"

priceSource = input.source(
     close,
     "Price Source",
     group = groupCore
)

priceMaType = input.string(
     "EMA",
     "Price MA Type",
     options = ["EMA", "SMA"],
     group = groupCore
)

priceMaLength = input.int(
     20,
     "Price MA Length",
     minval = 1,
     group = groupCore,
     tooltip = "Default 20. This smooths price before its slope is measured."
)

volumeMaType = input.string(
     "EMA",
     "Volume MA Type",
     options = ["EMA", "SMA"],
     group = groupCore
)

volumeMaLength = input.int(
     20,
     "Volume MA Length",
     minval = 1,
     group = groupCore,
     tooltip = "Default 20. Using the same length as price keeps both measurements on a similar market horizon."
)

slopeLength = input.int(
     5,
     "Slope Length",
     minval = 1,
     group = groupCore,
     tooltip = "Measures percentage change over this many candles."
)

normalizationLength = input.int(
     100,
     "Normalization Length",
     minval = 10,
     group = groupCore,
     tooltip = "Normalizes price and volume slopes so they can be compared on one scale."
)

componentSmoothing = input.int(
     3,
     "Price/Volume Line Smoothing",
     minval = 1,
     group = groupCore,
     tooltip = "Smooths the normalized Price Slope and Volume Slope lines."
)

differenceSmoothing = input.int(
     3,
     "Difference Smoothing",
     minval = 1,
     group = groupCore,
     tooltip = "Smooths the Price minus Volume difference oscillator."
)

signalLength = input.int(
     9,
     "Difference Signal Length",
     minval = 1,
     group = groupCore,
     tooltip = "EMA signal line of the Price minus Volume difference."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE AND VOLUME SLOPES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priceMa  = f_ma(priceSource, priceMaLength, priceMaType)
volumeMa = f_ma(volume, volumeMaLength, volumeMaType)

priceSlopePct =
     not na(priceMa[slopeLength]) and priceMa[slopeLength] != 0.0 ?
     ((priceMa - priceMa[slopeLength]) / priceMa[slopeLength]) * 100.0 :
     0.0

volumeSlopePct =
     not na(volumeMa[slopeLength]) and volumeMa[slopeLength] != 0.0 ?
     ((volumeMa - volumeMa[slopeLength]) / volumeMa[slopeLength]) * 100.0 :
     0.0

priceSlopeBase  = ta.ema(math.abs(priceSlopePct), normalizationLength)
volumeSlopeBase = ta.ema(math.abs(volumeSlopePct), normalizationLength)

priceNormRaw  = f_safe_div(priceSlopePct, priceSlopeBase)
volumeNormRaw = f_safe_div(volumeSlopePct, volumeSlopeBase)

priceNorm  = f_clamp(priceNormRaw, -3.0, 3.0) / 3.0
volumeNorm = f_clamp(volumeNormRaw, -3.0, 3.0) / 3.0

// Separate normalized components on the same -100 to +100 scale.
priceSlopeLine  = ta.ema(priceNorm * 100.0, componentSmoothing)
volumeSlopeLine = ta.ema(volumeNorm * 100.0, componentSmoothing)

// Main comparison:
// Positive = normalized price slope is above normalized volume slope.
// Negative = normalized price slope is below normalized volume slope.
rawDifference = priceSlopeLine - volumeSlopeLine
differenceOscillator = ta.ema(rawDifference, differenceSmoothing)
differenceSignal = ta.ema(differenceOscillator, signalLength)

// Price efficiency: large normalized price movement relative to volume movement.
priceEfficiency = f_safe_div(math.abs(priceNorm), math.abs(volumeNorm) + 0.20)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REGIME CLASSIFICATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupRegime = "Regime Thresholds"

flatPriceThreshold = input.float(
     0.12,
     "Flat Price Threshold",
     minval = 0.0,
     maxval = 1.0,
     step = 0.01,
     group = groupRegime
)

highVolumeThreshold = input.float(
     0.45,
     "High Volume Threshold",
     minval = 0.0,
     maxval = 1.0,
     step = 0.05,
     group = groupRegime
)

strongMoveThreshold = input.float(
     0.45,
     "Strong Price Move Threshold",
     minval = 0.0,
     maxval = 1.0,
     step = 0.05,
     group = groupRegime
)

efficientMoveThreshold = input.float(
     1.40,
     "Efficient Move Threshold",
     minval = 0.1,
     step = 0.1,
     group = groupRegime
)

priceUp   = priceNorm > flatPriceThreshold
priceDown = priceNorm < -flatPriceThreshold
priceFlat = math.abs(priceNorm) <= flatPriceThreshold

volumeUp   = volumeNorm > 0.0
volumeDown = volumeNorm < 0.0

strongBull =
     priceNorm >= strongMoveThreshold and
     volumeNorm >= highVolumeThreshold

smartMoneyBull =
     priceUp and
     volumeDown and
     priceEfficiency >= efficientMoveThreshold

strongBear =
     priceNorm <= -strongMoveThreshold and
     volumeNorm >= highVolumeThreshold

capitulation =
     priceNorm <= -strongMoveThreshold and
     volumeNorm >= highVolumeThreshold * 1.25

distribution =
     priceFlat and
     volumeNorm >= highVolumeThreshold

accumulation =
     priceFlat and
     volumeNorm <= -highVolumeThreshold

bullishWeakening =
     priceUp and
     volumeDown and
     not smartMoneyBull

bearishWeakening =
     priceDown and
     volumeDown

neutralRegime =
     not strongBull and
     not smartMoneyBull and
     not strongBear and
     not capitulation and
     not distribution and
     not accumulation and
     not bullishWeakening and
     not bearishWeakening

regimeText =
     capitulation ? "Capitulation / Heavy Selling" :
     strongBull ? "Strong Bullish Participation" :
     smartMoneyBull ? "Efficient Bullish Move" :
     strongBear ? "Strong Bearish Participation" :
     distribution ? "High Volume / Flat Price" :
     accumulation ? "Low Volume / Flat Price" :
     bullishWeakening ? "Bullish Move Weakening" :
     bearishWeakening ? "Bearish Move Weakening" :
     "Neutral"

regimeColor =
     capitulation ? color.rgb(210, 90, 0) :
     strongBull ? color.rgb(0, 110, 45) :
     smartMoneyBull ? color.rgb(0, 145, 100) :
     strongBear ? color.rgb(180, 25, 25) :
     distribution ? color.purple :
     accumulation ? color.teal :
     bullishWeakening ? color.rgb(120, 180, 90) :
     bearishWeakening ? color.rgb(125, 65, 145) :
     color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDisplay = "Oscillator Display"

showPriceSlopeLine = input.bool(
     true,
     "Show Price Slope Line",
     group = groupDisplay,
     tooltip = "Blue line: normalized slope of the selected Price MA."
)

showVolumeSlopeLine = input.bool(
     true,
     "Show Volume Slope Line",
     group = groupDisplay,
     tooltip = "Orange line: normalized slope of the selected Volume MA."
)

showDifferenceHistogram = input.bool(
     false,
     "Show Price − Volume Histogram",
     group = groupDisplay
)

showDifferenceLine = input.bool(
     false,
     "Show Price − Volume Line",
     group = groupDisplay
)

showDifferenceSignal = input.bool(
     false,
     "Show Difference Signal Line",
     group = groupDisplay
)

showBackground = input.bool(
     false,
     "Colour Regime Background",
     group = groupDisplay
)

priceLineColor = input.color(
     color.blue,
     "Price Slope Colour",
     group = groupDisplay
)

volumeLineColor = input.color(
     color.orange,
     "Volume Slope Colour",
     group = groupDisplay
)

differenceLineColor = input.color(
     color.white,
     "Price − Volume Colour",
     group = groupDisplay
)

differenceSignalColor = input.color(
     color.gray,
     "Difference Signal Colour",
     group = groupDisplay
)

upperLevel = input.float(50.0, "Upper Reference", step = 5.0, group = groupDisplay)
lowerLevel = input.float(-50.0, "Lower Reference", step = 5.0, group = groupDisplay)

plot(
     showPriceSlopeLine ? priceSlopeLine : na,
     title = "Normalized Price Slope",
     color = priceLineColor,
     linewidth = 2
)

plot(
     showVolumeSlopeLine ? volumeSlopeLine : na,
     title = "Normalized Volume Slope",
     color = volumeLineColor,
     linewidth = 2
)

plot(
     showDifferenceHistogram ? differenceOscillator : na,
     title = "Price Minus Volume Histogram",
     style = plot.style_columns,
     color = differenceOscillator >= 0.0 ?
          color.new(color.green, 25) :
          color.new(color.red, 25),
     linewidth = 2
)

plot(
     showDifferenceLine ? differenceOscillator : na,
     title = "Price Minus Volume Difference",
     color = differenceLineColor,
     linewidth = 2
)

plot(
     showDifferenceSignal ? differenceSignal : na,
     title = "Difference Signal",
     color = differenceSignalColor,
     linewidth = 1
)

hline(0.0, "Zero", color = color.gray)
hline(upperLevel, "Upper Reference", color = color.new(color.gray, 65), linestyle = hline.style_dotted)
hline(lowerLevel, "Lower Reference", color = color.new(color.gray, 65), linestyle = hline.style_dotted)

bgcolor(
     showBackground ? color.new(regimeColor, 90) : na,
     title = "Regime Background"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REGIME CHANGE MARKERS
// Tooltip-enabled labels are used instead of plotshape()
// because plotshape() cannot display hover explanations.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMarkers = "Regime Change Markers"

showRegimeMarkers = input.bool(
     true,
     "Show Regime Change Markers",
     group = groupMarkers
)

regimeMarkerSpacing = input.float(
     8.0,
     "Regime Marker Stack Spacing",
     minval = 1.0,
     step = 1.0,
     group = groupMarkers,
     tooltip = "Separates regime markers vertically when several appear near the same oscillator level."
)

newStrongBull = strongBull and not strongBull[1]
newSmartMoneyBull = smartMoneyBull and not smartMoneyBull[1]
newStrongBear = strongBear and not strongBear[1]
newCapitulation = capitulation and not capitulation[1]
newDistribution = distribution and not distribution[1]
newAccumulation = accumulation and not accumulation[1]

strongBullMarkerLevel      = differenceOscillator + regimeMarkerSpacing
efficientBullMarkerLevel   = differenceOscillator + regimeMarkerSpacing * 2.0
strongBearMarkerLevel      = differenceOscillator - regimeMarkerSpacing
capitulationMarkerLevel    = differenceOscillator - regimeMarkerSpacing * 2.0
distributionMarkerLevel    = differenceOscillator + regimeMarkerSpacing * 3.0
accumulationMarkerLevel    = differenceOscillator - regimeMarkerSpacing * 3.0

if showRegimeMarkers and newStrongBull
    label.new(
         bar_index,
         strongBullMarkerLevel,
         "SB",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_circle,
         color = color.rgb(0, 110, 45),
         textcolor = color.white,
         size = size.tiny,
         tooltip =
              "SB — Strong Bull Begins\n\n" +
              "Price slope is strongly positive and volume slope is also rising.\n" +
              "Volume is supporting the bullish move.\n\n" +
              "This is a bullish participation signal, not a guaranteed entry."
    )

if showRegimeMarkers and newSmartMoneyBull
    label.new(
         bar_index,
         efficientBullMarkerLevel,
         "EB",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_circle,
         color = color.rgb(0, 145, 100),
         textcolor = color.white,
         size = size.tiny,
         tooltip =
              "EB — Efficient Bull Begins\n\n" +
              "Price slope is rising efficiently while volume slope is falling.\n" +
              "Price is advancing without requiring increasing participation.\n\n" +
              "This can be efficient demand, but also watch for later exhaustion."
    )

if showRegimeMarkers and newStrongBear
    label.new(
         bar_index,
         strongBearMarkerLevel,
         "SBr",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_circle,
         color = color.rgb(180, 25, 25),
         textcolor = color.white,
         size = size.tiny,
         tooltip =
              "SBr — Strong Bear Begins\n\n" +
              "Price slope is strongly negative while volume slope is rising.\n" +
              "Increasing participation is supporting the decline.\n\n" +
              "This is a bearish participation signal, not an automatic short."
    )

if showRegimeMarkers and newCapitulation
    label.new(
         bar_index,
         capitulationMarkerLevel,
         "CAP",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_diamond,
         color = color.orange,
         textcolor = color.black,
         size = size.tiny,
         tooltip =
              "CAP — Capitulation Begins\n\n" +
              "Price is falling strongly while volume participation is elevated.\n" +
              "This may be aggressive bearish continuation or panic selling near exhaustion.\n\n" +
              "A bullish interpretation requires rejection, absorption, or structure recovery."
    )

if showRegimeMarkers and newDistribution
    label.new(
         bar_index,
         distributionMarkerLevel,
         "DIST",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_square,
         color = color.purple,
         textcolor = color.white,
         size = size.tiny,
         tooltip =
              "DIST — High Volume / Flat Price\n\n" +
              "Price slope is relatively flat while volume participation is elevated.\n" +
              "Large activity is producing little price progress.\n\n" +
              "This may indicate absorption or distribution; direction needs price confirmation."
    )

if showRegimeMarkers and newAccumulation
    label.new(
         bar_index,
         accumulationMarkerLevel,
         "ACC",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_square,
         color = color.teal,
         textcolor = color.white,
         size = size.tiny,
         tooltip =
              "ACC — Low Volume / Flat Price\n\n" +
              "Price slope is relatively flat while volume participation is falling.\n" +
              "The market is quiet and directional commitment is weak.\n\n" +
              "Treat this as compression, not a confirmed bullish signal."
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT DIVERGENCE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDiv = "Pivot Divergences"

enableDivergences = input.bool(true, "Enable Pivot Signals", group = groupDiv)

pivotLeftBars = input.int(
     5,
     "Pivot Left Bars",
     minval = 1,
     group = groupDiv
)

pivotRightBars = input.int(
     2,
     "Confirmation Candles",
     minval = 1,
     group = groupDiv,
     tooltip = "Signals are known after this many closed candles and are plotted on the original pivot."
)

pivotVolumeMode = input.string(
     "Pivot candle volume",
     "Pivot Volume Comparison",
     options = ["Pivot candle volume", "Average volume around pivot"],
     group = groupDiv
)

pivotVolumeAverageLength = input.int(
     3,
     "Pivot Volume Average Length",
     minval = 1,
     group = groupDiv
)

minimumPriceDifference = input.float(
     0.0,
     "Minimum Price Difference (%)",
     minval = 0.0,
     step = 0.1,
     group = groupDiv
)

minimumVolumeDifference = input.float(
     0.0,
     "Minimum Volume Difference (%)",
     minval = 0.0,
     step = 1.0,
     group = groupDiv
)

maximumPivotDistance = input.int(
     100,
     "Maximum Distance Between Pivots",
     minval = 2,
     group = groupDiv
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIVERGENCE DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDivDisplay = "Divergence Display"

showBearishWeakening = input.bool(true, "Show P↑ V↓", group = groupDivDisplay)
showBullishWeakening = input.bool(true, "Show P↓ V↓", group = groupDivDisplay)
showBuyingClimax = input.bool(true, "Show P↑ V↑", group = groupDivDisplay)
showSellingClimax = input.bool(true, "Show P↓ V↑", group = groupDivDisplay)
showDivergenceLabels = input.bool(false, "Show Full Signal Labels", group = groupDivDisplay)

showShapeSignals = input.bool(
     true,
     "Show Compact Tooltip Shapes",
     group = groupDivDisplay,
     tooltip = "Shows compact BW, BuW, BC and SC shape markers. Hover over each shape for the full signal name and explanation."
)

signalStackSpacing = input.float(
     16.0,
     "Signal Stack Spacing",
     minval = 1.0,
     step = 1.0,
     group = groupDivDisplay,
     tooltip = "Separates the four signal families vertically so labels do not sit on top of each other."
)

bearishWeakeningLevel = upperLevel + signalStackSpacing
buyingClimaxLevel      = upperLevel + signalStackSpacing * 2.0
bullishWeakeningLevel  = lowerLevel - signalStackSpacing
sellingClimaxLevel     = lowerLevel - signalStackSpacing * 2.0

bearishWeakeningColor = input.color(color.purple, "P↑ V↓ Colour", group = groupDivDisplay)
bullishWeakeningColor = input.color(color.rgb(0, 100, 0), "P↓ V↓ Colour", group = groupDivDisplay)
buyingClimaxColor = input.color(color.red, "P↑ V↑ Colour", group = groupDivDisplay)
sellingClimaxColor = input.color(color.lime, "P↓ V↑ Colour", group = groupDivDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pricePivotHigh = ta.pivothigh(high, pivotLeftBars, pivotRightBars)
pricePivotLow  = ta.pivotlow(low, pivotLeftBars, pivotRightBars)

newPivotHigh = not na(pricePivotHigh)
newPivotLow  = not na(pricePivotLow)

pivotBar = bar_index - pivotRightBars

pivotVolumeAverage = ta.sma(volume, pivotVolumeAverageLength)

pivotVolume =
     pivotVolumeMode == "Pivot candle volume" ?
     volume[pivotRightBars] :
     pivotVolumeAverage[pivotRightBars]

var float previousPriceHigh  = na
var float previousHighVolume = na
var int   previousHighBar    = na

var float previousPriceLow  = na
var float previousLowVolume = na
var int   previousLowBar    = na

bool bearishWeakeningSignal = false
bool bullishWeakeningSignal = false
bool buyingClimaxSignal = false
bool sellingClimaxSignal = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if enableDivergences and newPivotHigh and not na(pivotVolume)
    currentPriceHigh = pricePivotHigh
    currentHighVolume = pivotVolume

    hasPreviousHigh =
         not na(previousPriceHigh) and
         not na(previousHighVolume) and
         not na(previousHighBar)

    highDistance = hasPreviousHigh ? pivotBar - previousHighBar : na

    priceIncreasePct =
         hasPreviousHigh and previousPriceHigh != 0.0 ?
         ((currentPriceHigh - previousPriceHigh) / previousPriceHigh) * 100.0 :
         na

    highVolumeChangePct =
         hasPreviousHigh and previousHighVolume != 0.0 ?
         ((currentHighVolume - previousHighVolume) / previousHighVolume) * 100.0 :
         na

    validHigherHigh =
         hasPreviousHigh and
         currentPriceHigh > previousPriceHigh and
         priceIncreasePct >= minimumPriceDifference

    validDistance =
         hasPreviousHigh and
         highDistance > 0 and
         highDistance <= maximumPivotDistance

    lowerVolume =
         hasPreviousHigh and
         currentHighVolume < previousHighVolume and
         math.abs(highVolumeChangePct) >= minimumVolumeDifference

    higherVolume =
         hasPreviousHigh and
         currentHighVolume > previousHighVolume and
         highVolumeChangePct >= minimumVolumeDifference

    bearishWeakeningSignal := validHigherHigh and lowerVolume and validDistance
    buyingClimaxSignal := validHigherHigh and higherVolume and validDistance

    if bearishWeakeningSignal and showBearishWeakening and showDivergenceLabels
        label.new(
             pivotBar,
             bearishWeakeningLevel,
             "BW\nP↑ V↓",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = bearishWeakeningColor,
             textcolor = color.white,
             size = size.small,
             tooltip =
                  "BW — Bearish Weakening\n\n" +
                  "Price made a higher high while volume made a lower reading.\n" +
                  "The rally is advancing with weaker buyer participation.\n\n" +
                  "Price increase: " + str.tostring(priceIncreasePct, "#.##") + "%\n" +
                  "Volume reduction: " + str.tostring(math.abs(highVolumeChangePct), "#.##") + "%\n\n" +
                  "Warning only: wait for rejection or bearish structure confirmation."
        )

    if bearishWeakeningSignal and showBearishWeakening and showShapeSignals
        label.new(
             pivotBar,
             bearishWeakeningLevel,
             "BW",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_triangledown,
             color = bearishWeakeningColor,
             textcolor = color.white,
             size = size.tiny,
             tooltip =
                  "BW — Bearish Weakening\n\n" +
                  "Price made a higher high while volume decreased.\n" +
                  "Buyer participation is weakening, so the rally may be losing strength.\n\n" +
                  "Price increase: " + str.tostring(priceIncreasePct, "#.##") + "%\n" +
                  "Volume reduction: " + str.tostring(math.abs(highVolumeChangePct), "#.##") + "%\n\n" +
                  "Wait for rejection or bearish structure confirmation."
        )

    if buyingClimaxSignal and showBuyingClimax and showDivergenceLabels
        label.new(
             pivotBar,
             buyingClimaxLevel,
             "BC\nP↑ V↑",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = buyingClimaxColor,
             textcolor = color.white,
             size = size.small,
             tooltip =
                  "BC — Buying Climax / Strong Demand\n\n" +
                  "Price made a higher high while volume increased.\n" +
                  "This can confirm bullish continuation or mark climax buying near a top.\n\n" +
                  "Bearish only after rejection, absorption, or a bearish structure change."
        )

    if buyingClimaxSignal and showBuyingClimax and showShapeSignals
        label.new(
             pivotBar,
             buyingClimaxLevel,
             "BC",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_diamond,
             color = buyingClimaxColor,
             textcolor = color.white,
             size = size.tiny,
             tooltip =
                  "BC — Buying Climax / Strong Demand\n\n" +
                  "Price made a higher high while volume increased.\n" +
                  "This may be healthy bullish continuation or climax buying absorbed near a top.\n\n" +
                  "It becomes bearish only after rejection, absorption, or bearish structure confirmation."
        )

    previousPriceHigh := currentPriceHigh
    previousHighVolume := currentHighVolume
    previousHighBar := pivotBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOW PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if enableDivergences and newPivotLow and not na(pivotVolume)
    currentPriceLow = pricePivotLow
    currentLowVolume = pivotVolume

    hasPreviousLow =
         not na(previousPriceLow) and
         not na(previousLowVolume) and
         not na(previousLowBar)

    lowDistance = hasPreviousLow ? pivotBar - previousLowBar : na

    priceDecreasePct =
         hasPreviousLow and previousPriceLow != 0.0 ?
         ((previousPriceLow - currentPriceLow) / previousPriceLow) * 100.0 :
         na

    lowVolumeChangePct =
         hasPreviousLow and previousLowVolume != 0.0 ?
         ((currentLowVolume - previousLowVolume) / previousLowVolume) * 100.0 :
         na

    validLowerLow =
         hasPreviousLow and
         currentPriceLow < previousPriceLow and
         priceDecreasePct >= minimumPriceDifference

    validDistance =
         hasPreviousLow and
         lowDistance > 0 and
         lowDistance <= maximumPivotDistance

    lowerVolume =
         hasPreviousLow and
         currentLowVolume < previousLowVolume and
         math.abs(lowVolumeChangePct) >= minimumVolumeDifference

    higherVolume =
         hasPreviousLow and
         currentLowVolume > previousLowVolume and
         lowVolumeChangePct >= minimumVolumeDifference

    bullishWeakeningSignal := validLowerLow and lowerVolume and validDistance
    sellingClimaxSignal := validLowerLow and higherVolume and validDistance

    if bullishWeakeningSignal and showBullishWeakening and showDivergenceLabels
        label.new(
             pivotBar,
             bullishWeakeningLevel,
             "BuW\nP↓ V↓",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = bullishWeakeningColor,
             textcolor = color.white,
             size = size.small,
             tooltip =
                  "BuW — Bullish Weakening\n\n" +
                  "Price made a lower low while volume made a lower reading.\n" +
                  "The decline is continuing with weaker seller participation.\n\n" +
                  "Price decrease: " + str.tostring(priceDecreasePct, "#.##") + "%\n" +
                  "Volume reduction: " + str.tostring(math.abs(lowVolumeChangePct), "#.##") + "%\n\n" +
                  "Warning only: wait for rejection or bullish structure confirmation."
        )

    if bullishWeakeningSignal and showBullishWeakening and showShapeSignals
        label.new(
             pivotBar,
             bullishWeakeningLevel,
             "BuW",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_triangleup,
             color = bullishWeakeningColor,
             textcolor = color.white,
             size = size.tiny,
             tooltip =
                  "BuW — Bullish Weakening\n\n" +
                  "Price made a lower low while volume decreased.\n" +
                  "Seller participation is weakening, so the decline may be losing strength.\n\n" +
                  "Price decrease: " + str.tostring(priceDecreasePct, "#.##") + "%\n" +
                  "Volume reduction: " + str.tostring(math.abs(lowVolumeChangePct), "#.##") + "%\n\n" +
                  "Wait for rejection or bullish structure confirmation."
        )

    if sellingClimaxSignal and showSellingClimax and showDivergenceLabels
        label.new(
             pivotBar,
             sellingClimaxLevel,
             "SC\nP↓ V↑",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = sellingClimaxColor,
             textcolor = color.black,
             size = size.small,
             tooltip =
                  "SC — Selling Climax / Strong Supply\n\n" +
                  "Price made a lower low while volume increased.\n" +
                  "This can confirm bearish continuation or mark panic selling near a bottom.\n\n" +
                  "Bullish only after rejection, absorption, or a bullish structure change."
        )

    if sellingClimaxSignal and showSellingClimax and showShapeSignals
        label.new(
             pivotBar,
             sellingClimaxLevel,
             "SC",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_diamond,
             color = sellingClimaxColor,
             textcolor = color.black,
             size = size.tiny,
             tooltip =
                  "SC — Selling Climax / Strong Supply\n\n" +
                  "Price made a lower low while volume increased.\n" +
                  "This may be strong bearish continuation or panic selling absorbed near a bottom.\n\n" +
                  "It becomes bullish only after rejection, absorption, or bullish structure confirmation."
        )

    previousPriceLow := currentPriceLow
    previousLowVolume := currentLowVolume
    previousLowBar := pivotBar

// Compact shapes are created with label.new rather than plotshape.
// This allows each shape to display its signal name and explanation on hover.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupTable = "Status Table"

showTable = input.bool(true, "Show Status Table", group = groupTable)

tablePosition = input.string(
     "Top Right",
     "Table Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"],
     group = groupTable
)

selectedTablePosition =
     tablePosition == "Top Left" ? position.top_left :
     tablePosition == "Bottom Left" ? position.bottom_left :
     tablePosition == "Bottom Right" ? position.bottom_right :
     position.top_right

var table statusTable = table.new(
     selectedTablePosition,
     2,
     7,
     border_width = 1
)

if barstate.islast
    if showTable
        table.cell(statusTable, 0, 0, "Regime", text_color = color.white, bgcolor = color.rgb(45, 45, 45))
        table.cell(statusTable, 1, 0, regimeText, text_color = color.white, bgcolor = regimeColor)

        table.cell(statusTable, 0, 1, "Price slope", text_color = color.white, bgcolor = color.rgb(45, 45, 45))
        table.cell(
             statusTable,
             1,
             1,
             str.tostring(priceSlopePct, "#.##") + "%",
             text_color = priceSlopePct >= 0.0 ? color.lime : color.red
        )

        table.cell(statusTable, 0, 2, "Volume slope", text_color = color.white, bgcolor = color.rgb(45, 45, 45))
        table.cell(
             statusTable,
             1,
             2,
             str.tostring(volumeSlopePct, "#.##") + "%",
             text_color = volumeSlopePct >= 0.0 ? color.lime : color.red
        )

        table.cell(statusTable, 0, 3, "Efficiency", text_color = color.white, bgcolor = color.rgb(45, 45, 45))
        table.cell(statusTable, 1, 3, str.tostring(priceEfficiency, "#.##"), text_color = color.white)

        table.cell(statusTable, 0, 4, "Price line", text_color = color.white, bgcolor = color.rgb(45, 45, 45))
        table.cell(
             statusTable,
             1,
             4,
             str.tostring(priceSlopeLine, "#.##"),
             text_color = priceLineColor
        )

        table.cell(statusTable, 0, 5, "Volume line", text_color = color.white, bgcolor = color.rgb(45, 45, 45))
        table.cell(
             statusTable,
             1,
             5,
             str.tostring(volumeSlopeLine, "#.##"),
             text_color = volumeLineColor
        )

        table.cell(statusTable, 0, 6, "Price − Volume", text_color = color.white, bgcolor = color.rgb(45, 45, 45))
        table.cell(
             statusTable,
             1,
             6,
             str.tostring(differenceOscillator, "#.##"),
             text_color = differenceOscillator >= 0.0 ? color.lime : color.red
        )
    else
        table.clear(statusTable, 0, 0, 1, 6)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(newStrongBull, "Strong Bullish Participation", "Price and volume slopes are strongly bullish.")
alertcondition(newSmartMoneyBull, "Efficient Bullish Move", "Price is rising efficiently while volume slope is falling.")
alertcondition(newStrongBear, "Strong Bearish Participation", "Price is falling while volume participation is rising.")
alertcondition(newCapitulation, "Capitulation / Heavy Selling", "Price is falling strongly with elevated volume participation.")
alertcondition(newDistribution, "High Volume / Flat Price", "Price is relatively flat while volume participation is elevated.")
alertcondition(newAccumulation, "Low Volume / Flat Price", "Price is relatively flat while volume participation is falling.")

alertcondition(
     ta.crossover(priceSlopeLine, volumeSlopeLine),
     "Price Slope Crossed Above Volume Slope",
     "The normalized Price Slope crossed above the normalized Volume Slope."
)

alertcondition(
     ta.crossunder(priceSlopeLine, volumeSlopeLine),
     "Price Slope Crossed Below Volume Slope",
     "The normalized Price Slope crossed below the normalized Volume Slope."
)

alertcondition(
     ta.crossover(differenceOscillator, 0.0),
     "Price Minus Volume Crossed Above Zero",
     "The Price minus Volume difference crossed above zero."
)

alertcondition(
     ta.crossunder(differenceOscillator, 0.0),
     "Price Minus Volume Crossed Below Zero",
     "The Price minus Volume difference crossed below zero."
)

alertcondition(
     bearishWeakeningSignal,
     "P↑ V↓ Bearish Weakening",
     "Price formed a higher high while pivot volume decreased."
)

alertcondition(
     bullishWeakeningSignal,
     "P↓ V↓ Bullish Weakening",
     "Price formed a lower low while pivot volume decreased."
)

alertcondition(
     buyingClimaxSignal,
     "P↑ V↑ High-Volume Higher High",
     "Price formed a higher high while pivot volume increased."
)

alertcondition(
     sellingClimaxSignal,
     "P↓ V↑ High-Volume Lower Low",
     "Price formed a lower low while pivot volume increased."
)
````
