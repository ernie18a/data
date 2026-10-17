# Price Volume Divergence Signals

- url: https://www.tradingview.com/script/NTBg8HEy-Price-Volume-Divergence-Signals/
- type: indicator
- pine_id: PUB;e3cea682d80f48508bc8136604505ead
- version: 3.0

## Description

# Price Volume Divergence Signals

**Price Volume Divergence Signals** identifies moments when **price and volume stop moving together**, often revealing that the current trend is losing participation before price reverses.

Unlike traditional indicators that focus only on price, this script measures whether **buyers or sellers are still committing capital** to the move.

## Signals

### 🟣 P↑ V↓ — Bearish Price–Volume Divergence

Price makes a **Higher High** while volume makes a **Lower High**.

This suggests buyers managed to push price higher, but with **less participation** than before. The rally may be weakening and becoming vulnerable to a reversal or pullback.

**Interpretation**

* Higher High
* Lower Volume
* Buyer participation is fading
* Bearish warning (not a sell signal by itself)

---

### 🟢 P↓ V↓ — Bullish Price–Volume Divergence

Price makes a **Lower Low** while volume makes a **Lower Low**.

This suggests sellers managed to push price lower, but with **less participation** than during the previous decline. Selling pressure may be exhausting.

**Interpretation**

* Lower Low
* Lower Volume
* Seller participation is fading
* Bullish warning (not a buy signal by itself)

## Features

* Confirmed pivot detection (no repaint after confirmation)
* Configurable pivot strength
* Adjustable confirmation candles
* Compare either:

  * Pivot candle volume
  * Average volume around the pivot
* Minimum price difference filter
* Minimum volume reduction filter
* Maximum distance between pivots filter
* Optional divergence lines
* Hover tooltips explaining every signal
* TradingView alerts for bullish and bearish divergences

## How to Use

These signals work best as **early warning signs**, not standalone entry signals.

Look for confluence with:

* Support and resistance
* Liquidity sweeps
* Wyckoff Springs and Upthrusts
* RSI or MACD divergences
* Volume climaxes
* Fair Value Gaps (FVG)
* Market structure shifts (CHoCH / BOS)

The highest-probability setups occur when multiple factors align.

## Notes

A divergence **does not predict an immediate reversal**. Markets can continue trending after a divergence appears.

Wait for price confirmation before entering a trade whenever possible.

The indicator only plots **confirmed pivots**, so signals do not repaint once they are printed.

---

Simple. Clean. Focused on one question:

**Is price still being supported by participation, or is the move running out of fuel?**

## Source Code

````pine
//@version=6
indicator(
     "Price and Volume Divergence + Market Phases",
     shorttitle = "Price Volume Signals",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DETECTION SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDetection = "Detection"

leftBars = input.int(
     5,
     "Pivot Left Bars",
     minval = 1,
     group = groupDetection,
     tooltip = "Number of candles required to the left of a pivot."
)

rightBars = input.int(
     2,
     "Confirmation Candles",
     minval = 1,
     group = groupDetection,
     tooltip = "Number of closed candles required after the pivot. Signals are placed on the original pivot candle."
)

comparisonMode = input.string(
     "Pivot candle volume",
     "Volume Comparison",
     options = [
          "Pivot candle volume",
          "Average volume around pivot"
     ],
     group = groupDetection,
     tooltip = "Compare volume on the exact pivot candles or use average volume around each pivot."
)

volumeAverageLength = input.int(
     3,
     "Volume Average Length",
     minval = 1,
     group = groupDetection,
     tooltip = "Used only when Average volume around pivot is selected."
)

minPriceDifference = input.float(
     0.0,
     "Minimum Price Difference (%)",
     minval = 0.0,
     step = 0.1,
     group = groupDetection,
     tooltip = "Minimum percentage difference required between the two price pivots."
)

minVolumeDifference = input.float(
     0.0,
     "Minimum Volume Difference (%)",
     minval = 0.0,
     step = 1.0,
     group = groupDetection,
     tooltip = "Minimum volume increase or reduction required between the two pivots."
)

maxPivotDistance = input.int(
     100,
     "Maximum Distance Between Pivots",
     minval = 2,
     group = groupDetection,
     tooltip = "Ignores comparisons when the two corresponding pivots are too far apart."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSignals = "Signals"

showBearishDivergence = input.bool(
     true,
     "Show Bearish Weakening — P↑ V↓",
     group = groupSignals
)

showBullishDivergence = input.bool(
     true,
     "Show Bullish Weakening — P↓ V↓",
     group = groupSignals
)

showBuyingClimax = input.bool(
     true,
     "Show Buying Climax — P↑ V↑",
     group = groupSignals
)

showSellingClimax = input.bool(
     true,
     "Show Selling Climax — P↓ V↑",
     group = groupSignals
)

showDivergenceLines = input.bool(
     true,
     "Draw Weakening Divergence Lines",
     group = groupSignals
)

showClimaxLines = input.bool(
     true,
     "Draw Climax Lines",
     group = groupSignals
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDisplay = "Display"

bearishDivergenceColor = input.color(
     color.purple,
     "Bearish Weakening Colour",
     group = groupDisplay
)

bullishDivergenceColor = input.color(
     color.rgb(0, 100, 0),
     "Bullish Weakening Colour",
     group = groupDisplay
)

buyingClimaxColor = input.color(
     color.red,
     "Buying Climax Colour",
     group = groupDisplay
)

sellingClimaxColor = input.color(
     color.lime,
     "Selling Climax Colour",
     group = groupDisplay
)

lineWidth = input.int(
     2,
     "Line Thickness",
     minval = 1,
     maxval = 5,
     group = groupDisplay
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKET PHASE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupPhase = "Market Phase"

phaseDisplayMode = input.string(
     "Candle Colours",
     "Market Phase Display",
     options = [
          "None",
          "Candle Colours",
          "Background",
          "Both"
     ],
     group = groupPhase,
     tooltip = "Choose whether the four price-volume phases colour the candles, the chart background, both, or neither."
)

showVolumeTable = input.bool(
     true,
     "Show Volume Activity Table",
     group = groupPhase
)

phasePriceLookback = input.int(
     1,
     "Price Direction Lookback",
     minval = 1,
     group = groupPhase,
     tooltip = "Current close is compared with the close this many candles ago."
)

phaseVolumeLookback = input.int(
     1,
     "Volume Direction Lookback",
     minval = 1,
     group = groupPhase,
     tooltip = "Current phase volume is compared with phase volume this many candles ago."
)

phaseVolumeSmoothing = input.int(
     1,
     "Volume Smoothing",
     minval = 1,
     group = groupPhase,
     tooltip = "1 uses raw candle volume. Higher values use a moving average to reduce noisy phase changes."
)

relativeVolumeLength = input.int(
     20,
     "Relative Volume Length",
     minval = 2,
     group = groupPhase,
     tooltip = "Used by the table to compare current volume with its longer-term average. It does not determine the phase."
)

phaseTrendLength = input.int(
     50,
     "Trend EMA Length",
     minval = 2,
     group = groupPhase,
     tooltip = "Used only to show broader trend context in the table. It does not determine the candle phase."
)

phaseTransparency = input.int(
     88,
     "Background Transparency",
     minval = 0,
     maxval = 100,
     group = groupPhase
)

bullishRallyColor    = input.color(color.white, "Bullish Rally — P↑ V↑", group = groupPhase)
bullishPullbackColor = input.color(color.yellow, "Bullish Pullback — P↓ V↓", group = groupPhase)
bearishPullbackColor = input.color(color.red, "Bearish Pullback — P↓ V↑", group = groupPhase)
bearishRallyColor    = input.color(color.purple, "Bearish Rally — P↑ V↓", group = groupPhase)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKET PHASE ENGINE
//
// Every candle is assigned to exactly one price-volume phase:
//
// P↑ V↑ = Bullish Rally
// P↓ V↓ = Bullish Pullback
// P↓ V↑ = Bearish Pullback
// P↑ V↓ = Bearish Rally
//
// Volume is an essential part of every classification.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
phaseVolume = phaseVolumeSmoothing == 1 ?
     volume :
     ta.sma(volume, phaseVolumeSmoothing)

priceReference  = close[phasePriceLookback]
volumeReference = phaseVolume[phaseVolumeLookback]

// Using >= for equal values guarantees that every available candle
// receives one of the four phase colours.
priceRising  = not na(priceReference) and close >= priceReference
priceFalling = not na(priceReference) and close < priceReference

volumeRising  = not na(volumeReference) and phaseVolume >= volumeReference
volumeFalling = not na(volumeReference) and phaseVolume < volumeReference

bullishRally    = priceRising and volumeRising
bullishPullback = priceFalling and volumeFalling
bearishPullback = priceFalling and volumeRising
bearishRally    = priceRising and volumeFalling

// Only the earliest candles without enough history need a fallback.
// The fallback still uses current candle price and volume information.
phaseReady = not na(priceReference) and not na(volumeReference)

fallbackPriceRising = close >= open
fallbackVolumeRising = na(volume[1]) ? true : volume >= volume[1]

resolvedBullishRally = phaseReady ?
     bullishRally :
     fallbackPriceRising and fallbackVolumeRising

resolvedBullishPullback = phaseReady ?
     bullishPullback :
     not fallbackPriceRising and not fallbackVolumeRising

resolvedBearishPullback = phaseReady ?
     bearishPullback :
     not fallbackPriceRising and fallbackVolumeRising

resolvedBearishRally = phaseReady ?
     bearishRally :
     fallbackPriceRising and not fallbackVolumeRising

string marketPhase = resolvedBullishRally ? "Bullish Rally" :
     resolvedBullishPullback ? "Bullish Pullback" :
     resolvedBearishPullback ? "Bearish Pullback" :
     "Bearish Rally"

string phaseFormula = resolvedBullishRally ? "Price ↑  Volume ↑" :
     resolvedBullishPullback ? "Price ↓  Volume ↓" :
     resolvedBearishPullback ? "Price ↓  Volume ↑" :
     "Price ↑  Volume ↓"

string priceActivity = priceRising ? "Rising" :
     priceFalling ? "Falling" :
     fallbackPriceRising ? "Rising" :
     "Falling"

string volumeActivity = volumeRising ? "Rising" :
     volumeFalling ? "Falling" :
     fallbackVolumeRising ? "Rising" :
     "Falling"

string phaseDescription = resolvedBullishRally ?
     "Price and volume are rising together.\nBuyers are supporting the advance." :
     resolvedBullishPullback ?
     "Price is falling while volume contracts.\nSelling participation is weakening." :
     resolvedBearishPullback ?
     "Price and volume are falling together.\nSellers are supporting the decline." :
     "Price is rising while volume contracts.\nBuying participation is weakening."

color phaseColor = resolvedBullishRally ? bullishRallyColor :
     resolvedBullishPullback ? bullishPullbackColor :
     resolvedBearishPullback ? bearishPullbackColor :
     bearishRallyColor

color phaseTextColor = resolvedBullishRally or resolvedBullishPullback ? color.black : color.white

bool showPhaseCandles = phaseDisplayMode == "Candle Colours" or phaseDisplayMode == "Both"
bool showPhaseBackground = phaseDisplayMode == "Background" or phaseDisplayMode == "Both"

barcolor(
     showPhaseCandles ? phaseColor : na,
     title = "Market Phase Candle Colours"
)

bgcolor(
     showPhaseBackground ? color.new(phaseColor, phaseTransparency) : na,
     title = "Market Phase Background"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME ACTIVITY TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendEma = ta.ema(close, phaseTrendLength)

bullEnvironment = close >= trendEma
bearEnvironment = close < trendEma

longVolumeAverage = ta.sma(volume, relativeVolumeLength)
relativeVolume = longVolumeAverage > 0 ? volume / longVolumeAverage : na

string relativeVolumeActivity = na(relativeVolume) ? "N/A" :
     relativeVolume >= 1.20 ? "High" :
     relativeVolume <= 0.80 ? "Low" :
     "Average"

var table volumeActivityTable = table.new(
     position.bottom_right,
     2,
     7,
     border_width = 1
)

if barstate.islast
    if showVolumeTable
        table.cell(
             volumeActivityTable,
             0,
             0,
             "VOLUME ACTIVITY",
             text_color = phaseTextColor,
             bgcolor = color.new(phaseColor, 15)
        )
        table.cell(
             volumeActivityTable,
             1,
             0,
             marketPhase,
             text_color = phaseTextColor,
             bgcolor = color.new(phaseColor, 15)
        )

        table.cell(volumeActivityTable, 0, 1, "Phase Rule", text_color = color.white, bgcolor = color.new(color.black, 20))
        table.cell(volumeActivityTable, 1, 1, phaseFormula, text_color = color.white)

        table.cell(volumeActivityTable, 0, 2, "Price Activity", text_color = color.white, bgcolor = color.new(color.black, 20))
        table.cell(volumeActivityTable, 1, 2, priceActivity, text_color = color.white)

        table.cell(volumeActivityTable, 0, 3, "Volume Activity", text_color = color.white, bgcolor = color.new(color.black, 20))
        table.cell(volumeActivityTable, 1, 3, volumeActivity, text_color = color.white)

        table.cell(volumeActivityTable, 0, 4, "Relative Volume", text_color = color.white, bgcolor = color.new(color.black, 20))
        table.cell(
             volumeActivityTable,
             1,
             4,
             na(relativeVolume) ?
                  "N/A" :
                  str.tostring(relativeVolume, "#.##") + "x — " + relativeVolumeActivity,
             text_color = color.white
        )

        table.cell(volumeActivityTable, 0, 5, "Broader Trend", text_color = color.white, bgcolor = color.new(color.black, 20))
        table.cell(
             volumeActivityTable,
             1,
             5,
             bullEnvironment ? "Above EMA — Bullish" : bearEnvironment ? "Below EMA — Bearish" : "Neutral",
             text_color = color.white
        )

        table.cell(volumeActivityTable, 0, 6, "Meaning", text_color = color.white, bgcolor = color.new(color.black, 20))
        table.cell(volumeActivityTable, 1, 6, phaseDescription, text_color = color.white)
    else
        table.clear(volumeActivityTable, 0, 0, 1, 6)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pricePivotHigh = ta.pivothigh(high, leftBars, rightBars)
pricePivotLow  = ta.pivotlow(low, leftBars, rightBars)

newPivotHigh = not na(pricePivotHigh)
newPivotLow  = not na(pricePivotLow)

pivotBar = bar_index - rightBars

volumeAverage = ta.sma(volume, volumeAverageLength)

pivotVolume = comparisonMode == "Pivot candle volume" ?
     volume[rightBars] :
     volumeAverage[rightBars]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVIOUS HIGH STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float previousPriceHigh  = na
var float previousHighVolume = na
var int   previousHighBar    = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVIOUS LOW STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float previousPriceLow  = na
var float previousLowVolume = na
var int   previousLowBar    = na

// Reset signals on every candle.
bool bearishDivergence = false
bool bullishDivergence = false
bool buyingClimax      = false
bool sellingClimax     = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH-PIVOT SIGNALS
//
// P↑ V↓ = bearish weakening divergence
// P↑ V↑ = possible buying climax
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newPivotHigh and not na(pivotVolume)
    currentPriceHigh  = pricePivotHigh
    currentHighVolume = pivotVolume

    hasPreviousHigh =
         not na(previousPriceHigh) and
         not na(previousHighVolume) and
         not na(previousHighBar)

    highDistance = hasPreviousHigh ?
         pivotBar - previousHighBar :
         na

    priceIncreasePct =
         hasPreviousHigh and previousPriceHigh != 0.0 ?
         ((currentPriceHigh - previousPriceHigh) /
         previousPriceHigh) * 100.0 :
         na

    highVolumeChangePct =
         hasPreviousHigh and previousHighVolume != 0.0 ?
         ((currentHighVolume - previousHighVolume) /
         previousHighVolume) * 100.0 :
         na

    higherHigh =
         hasPreviousHigh and
         currentPriceHigh > previousPriceHigh and
         priceIncreasePct >= minPriceDifference

    lowerVolumeAtHigh =
         hasPreviousHigh and
         currentHighVolume < previousHighVolume and
         math.abs(highVolumeChangePct) >= minVolumeDifference

    higherVolumeAtHigh =
         hasPreviousHigh and
         currentHighVolume > previousHighVolume and
         highVolumeChangePct >= minVolumeDifference

    validHighDistance =
         hasPreviousHigh and
         highDistance > 0 and
         highDistance <= maxPivotDistance

    bearishDivergence :=
         higherHigh and
         lowerVolumeAtHigh and
         validHighDistance

    buyingClimax :=
         higherHigh and
         higherVolumeAtHigh and
         validHighDistance

    //──────────────────────────────────────────────────
    // BEARISH WEAKENING
    //──────────────────────────────────────────────────
    if bearishDivergence
        bearishTooltip =
             "Bearish Price–Volume Weakening\n\n" +
             "Price made a higher high while volume decreased.\n\n" +
             "Buyers pushed price higher with less participation. " +
             "The rally may be losing strength.\n\n" +
             "Price increase: " +
             str.tostring(priceIncreasePct, "#.##") + "%\n" +
             "Volume reduction: " +
             str.tostring(math.abs(highVolumeChangePct), "#.##") + "%\n\n" +
             "Bearish warning only. Wait for price confirmation."

        if showBearishDivergence
            label.new(
                 pivotBar,
                 currentPriceHigh,
                 "P↑ V↓",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_down,
                 color = bearishDivergenceColor,
                 textcolor = color.white,
                 size = size.small,
                 tooltip = bearishTooltip
            )

        if showDivergenceLines
            line.new(
                 previousHighBar,
                 previousPriceHigh,
                 pivotBar,
                 currentPriceHigh,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = bearishDivergenceColor,
                 width = lineWidth
            )

    //──────────────────────────────────────────────────
    // BUYING CLIMAX
    //──────────────────────────────────────────────────
    if buyingClimax
        buyingClimaxTooltip =
             "Possible Buying Climax\n\n" +
             "Price made a higher high while volume increased.\n\n" +
             "This shows strong activity at the new high. It may be:\n" +
             "• Bullish continuation, or\n" +
             "• Climax buying absorbed by large sellers.\n\n" +
             "Price increase: " +
             str.tostring(priceIncreasePct, "#.##") + "%\n" +
             "Volume increase: " +
             str.tostring(highVolumeChangePct, "#.##") + "%\n\n" +
             "It becomes bearish only if price rejects the high " +
             "and confirms weakness."

        if showBuyingClimax
            label.new(
                 pivotBar,
                 currentPriceHigh,
                 "P↑ V↑",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_down,
                 color = buyingClimaxColor,
                 textcolor = color.white,
                 size = size.small,
                 tooltip = buyingClimaxTooltip
            )

        if showClimaxLines
            line.new(
                 previousHighBar,
                 previousPriceHigh,
                 pivotBar,
                 currentPriceHigh,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = buyingClimaxColor,
                 style = line.style_dashed,
                 width = lineWidth
            )

    previousPriceHigh  := currentPriceHigh
    previousHighVolume := currentHighVolume
    previousHighBar    := pivotBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOW-PIVOT SIGNALS
//
// P↓ V↓ = bullish weakening divergence
// P↓ V↑ = possible selling climax
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newPivotLow and not na(pivotVolume)
    currentPriceLow  = pricePivotLow
    currentLowVolume = pivotVolume

    hasPreviousLow =
         not na(previousPriceLow) and
         not na(previousLowVolume) and
         not na(previousLowBar)

    lowDistance = hasPreviousLow ?
         pivotBar - previousLowBar :
         na

    priceDecreasePct =
         hasPreviousLow and previousPriceLow != 0.0 ?
         ((previousPriceLow - currentPriceLow) /
         previousPriceLow) * 100.0 :
         na

    lowVolumeChangePct =
         hasPreviousLow and previousLowVolume != 0.0 ?
         ((currentLowVolume - previousLowVolume) /
         previousLowVolume) * 100.0 :
         na

    lowerLow =
         hasPreviousLow and
         currentPriceLow < previousPriceLow and
         priceDecreasePct >= minPriceDifference

    lowerVolumeAtLow =
         hasPreviousLow and
         currentLowVolume < previousLowVolume and
         math.abs(lowVolumeChangePct) >= minVolumeDifference

    higherVolumeAtLow =
         hasPreviousLow and
         currentLowVolume > previousLowVolume and
         lowVolumeChangePct >= minVolumeDifference

    validLowDistance =
         hasPreviousLow and
         lowDistance > 0 and
         lowDistance <= maxPivotDistance

    bullishDivergence :=
         lowerLow and
         lowerVolumeAtLow and
         validLowDistance

    sellingClimax :=
         lowerLow and
         higherVolumeAtLow and
         validLowDistance

    //──────────────────────────────────────────────────
    // BULLISH WEAKENING
    //──────────────────────────────────────────────────
    if bullishDivergence
        bullishTooltip =
             "Bullish Price–Volume Weakening\n\n" +
             "Price made a lower low while volume decreased.\n\n" +
             "Sellers pushed price lower with less participation. " +
             "Selling pressure may be weakening.\n\n" +
             "Price decrease: " +
             str.tostring(priceDecreasePct, "#.##") + "%\n" +
             "Volume reduction: " +
             str.tostring(math.abs(lowVolumeChangePct), "#.##") + "%\n\n" +
             "Bullish warning only. Wait for price confirmation."

        if showBullishDivergence
            label.new(
                 pivotBar,
                 currentPriceLow,
                 "P↓ V↓",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_up,
                 color = bullishDivergenceColor,
                 textcolor = color.white,
                 size = size.small,
                 tooltip = bullishTooltip
            )

        if showDivergenceLines
            line.new(
                 previousLowBar,
                 previousPriceLow,
                 pivotBar,
                 currentPriceLow,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = bullishDivergenceColor,
                 width = lineWidth
            )

    //──────────────────────────────────────────────────
    // SELLING CLIMAX
    //──────────────────────────────────────────────────
    if sellingClimax
        sellingClimaxTooltip =
             "Possible Selling Climax\n\n" +
             "Price made a lower low while volume increased.\n\n" +
             "This shows strong activity at the new low. It may be:\n" +
             "• Bearish continuation, or\n" +
             "• Panic selling absorbed by large buyers.\n\n" +
             "Price decrease: " +
             str.tostring(priceDecreasePct, "#.##") + "%\n" +
             "Volume increase: " +
             str.tostring(lowVolumeChangePct, "#.##") + "%\n\n" +
             "It becomes bullish only if price rejects the low " +
             "and confirms strength."

        if showSellingClimax
            label.new(
                 pivotBar,
                 currentPriceLow,
                 "P↓ V↑",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_up,
                 color = sellingClimaxColor,
                 textcolor = color.black,
                 size = size.small,
                 tooltip = sellingClimaxTooltip
            )

        if showClimaxLines
            line.new(
                 previousLowBar,
                 previousPriceLow,
                 pivotBar,
                 currentPriceLow,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = sellingClimaxColor,
                 style = line.style_dashed,
                 width = lineWidth
            )

    previousPriceLow  := currentPriceLow
    previousLowVolume := currentLowVolume
    previousLowBar    := pivotBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     bearishDivergence,
     title = "Bearish Price–Volume Weakening",
     message = "P↑ V↓: Price formed a higher high while volume decreased."
)

alertcondition(
     bullishDivergence,
     title = "Bullish Price–Volume Weakening",
     message = "P↓ V↓: Price formed a lower low while volume decreased."
)

alertcondition(
     buyingClimax,
     title = "Possible Buying Climax",
     message = "P↑ V↑: Price formed a higher high while volume increased. Watch for rejection or continuation."
)

alertcondition(
     sellingClimax,
     title = "Possible Selling Climax",
     message = "P↓ V↑: Price formed a lower low while volume increased. Watch for absorption or continuation."
)
````
