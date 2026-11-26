# Fast RSI Divergence at VWAP Signals

- url: https://www.tradingview.com/script/A3Ly1TBg-Fast-RSI-Divergence-at-VWAP-Signals/
- type: indicator
- pine_id: PUB;7480152087a14516b6170ffb61ef2d0a
- version: 1.0

## Description

# Fast RSI Divergence at VWAP Signals

Fast RSI Divergence at VWAP Signals is designed to identify early bullish and bearish RSI divergences while combining them with VWAP Standard Deviation bands to help highlight potential areas of price exhaustion.

Unlike traditional pivot-based divergence indicators that require multiple bars of confirmation, this script uses a dynamic reference-point approach. This allows divergences to be detected earlier while providing optional candle-close confirmation for traders who prefer additional validation.

## Features

• Fast bullish and bearish RSI divergence detection

• Dynamic reference-point algorithm instead of delayed pivot confirmation

• Daily anchored VWAP with configurable Standard Deviation bands

• Optional VWAP deviation filter

• Choice of wick-based or close-based divergence detection

• Optional candle-close confirmation

• Optional RSI momentum turn confirmation

• Optional candle direction confirmation

• Adjustable cooldown between consecutive signals

• Optional display of divergence reference points

• Built-in BUY and SELL alerts

## How It Works

The indicator continuously monitors RSI for overbought and oversold conditions.

When RSI reaches an extreme, a reference point is created. Instead of waiting for a confirmed pivot, the script immediately compares subsequent price action against that reference.

A bearish divergence is detected when:

• Price makes a higher high

• RSI forms a lower high

A bullish divergence is detected when:

• Price makes a lower low

• RSI forms a higher low

Additional filters can be enabled to require:

• Price touching or closing outside the selected VWAP Standard Deviation band

• RSI beginning to reverse direction

• Confirmation from candle direction

• Candle-close confirmation before the signal becomes final

After each confirmed signal, the reference point is automatically updated to prevent repeated signals from the same price movement.

## Recommended Usage

This indicator is designed to work best as part of a confluence-based trading approach rather than as a standalone signal generator.

For additional confirmation, it is recommended to use it together with **Bollinger Bands**. Confluence between RSI divergence, VWAP Standard Deviation extremes, and Bollinger Band extremes can help identify areas where price may be statistically extended.

Examples of higher-confluence setups include:

• Bullish RSI divergence occurring near both the lower VWAP Standard Deviation band and the lower Bollinger Band.

• Bearish RSI divergence occurring near both the upper VWAP Standard Deviation band and the upper Bollinger Band.

Additional confirmation from market structure, trend direction, support and resistance, or volume analysis may further improve trade selection.

## Inputs

The indicator provides extensive customization, including:

• RSI Length

• Overbought and Oversold Levels

• Maximum Divergence Lookback

• Minimum RSI Difference

• Minimum Price Extension

• VWAP Standard Deviation Multipliers

• Wick or Close Validation

• Candle Close Confirmation

• RSI Turn Confirmation

• Candle Direction Confirmation

• Signal Cooldown

• Display Options

## Alerts

Two alert conditions are included:

• Fast RSI Divergence BUY

• Fast RSI Divergence SELL

These alerts can be used with TradingView's alert system or external automation.

## Notes

This indicator is intended to highlight potential momentum exhaustion near statistically extended price levels. Divergence signals indicate that momentum and price are no longer moving in sync, but they do not necessarily imply an immediate reversal.

As with any technical analysis tool, signals should be interpreted within the broader market context. No indicator can predict future price movements with certainty.

## Source Code

````pine
//@version=6
indicator(
     "Fast RSI Divergence at VWAP StDev",
     shorttitle = "Fast RSI Div VWAP",
     overlay = true,
     max_labels_count = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupRSI = "RSI Divergence"

rsiLength = input.int(
     14,
     "RSI Length",
     minval = 1,
     group = groupRSI
)

oversold = input.float(
     30.0,
     "Oversold Level",
     minval = 1.0,
     maxval = 50.0,
     group = groupRSI
)

overbought = input.float(
     70.0,
     "Overbought Level",
     minval = 50.0,
     maxval = 99.0,
     group = groupRSI
)

bearReset = input.float(
     50.0,
     "Bear Divergence Reset Level",
     minval = 1.0,
     maxval = 99.0,
     group = groupRSI
)

bullReset = input.float(
     50.0,
     "Bull Divergence Reset Level",
     minval = 1.0,
     maxval = 99.0,
     group = groupRSI
)

lookbackBars = input.int(
     14,
     "Maximum Divergence Lookback",
     minval = 2,
     group = groupRSI
)

priceSourceMode = input.string(
     "Wicks",
     "Divergence Price Source",
     options = ["Wicks", "Close"],
     group = groupRSI,
     tooltip = "Wicks detects divergences earlier. Close is more conservative."
)

minimumRsiDifference = input.float(
     2.0,
     "Minimum RSI Difference",
     minval = 0.0,
     step = 0.25,
     group = groupRSI,
     tooltip = "The RSI must weaken or strengthen by at least this amount."
)

minimumPriceExtension = input.float(
     0.10,
     "Minimum Price Extension %",
     minval = 0.0,
     step = 0.05,
     group = groupRSI,
     tooltip = "Minimum higher-high or lower-low distance from the reference price."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupVWAP = "VWAP Standard Deviation"

useVWAPFilter = input.bool(
     true,
     "Require VWAP Deviation Touch",
     group = groupVWAP
)

upperDeviation = input.float(
     1.51,
     "Upper Standard Deviation",
     minval = 0.0,
     step = 0.01,
     group = groupVWAP
)

lowerDeviation = input.float(
     1.51,
     "Lower Standard Deviation",
     minval = 0.0,
     step = 0.01,
     group = groupVWAP
)

vwapValidationMode = input.string(
     "Wick Touch",
     "VWAP Validation",
     options = ["Wick Touch", "Close Outside"],
     group = groupVWAP,
     tooltip = "Wick Touch produces earlier signals. Close Outside is stricter."
)

showVWAP = input.bool(
     true,
     "Show VWAP",
     group = groupVWAP
)

showBands = input.bool(
     true,
     "Show Deviation Bands",
     group = groupVWAP
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupSignals = "Signal Confirmation"

confirmAtClose = input.bool(
     true,
     "Confirm Signal at Candle Close",
     group = groupSignals,
     tooltip = "Recommended. Signals will not be final until the candle closes."
)

requireCandleDirection = input.bool(
     false,
     "Require Confirmation Candle Direction",
     group = groupSignals,
     tooltip = "BUY requires a bullish candle. SELL requires a bearish candle."
)

requireRsiTurn = input.bool(
     true,
     "Require RSI to Turn",
     group = groupSignals,
     tooltip = "BUY requires RSI to stop falling. SELL requires RSI to stop rising."
)

cooldownBars = input.int(
     1,
     "Minimum Bars Between Same-Side Signals",
     minval = 0,
     group = groupSignals
)

showDivergenceMarkers = input.bool(
     true,
     "Show BUY / SELL Signals",
     group = groupSignals
)

showReferencePoints = input.bool(
     false,
     "Show Divergence Reference Points",
     group = groupSignals
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rsiValue = ta.rsi(close, rsiLength)

bearPriceSource = priceSourceMode == "Wicks" ? high : close
bullPriceSource = priceSourceMode == "Wicks" ? low : close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DAILY ANCHORED VWAP AND STANDARD DEVIATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

newDay = ta.change(time("D")) != 0

var float cumulativePriceVolume = 0.0
var float cumulativeVolume = 0.0
var float cumulativePriceSquaredVolume = 0.0

if newDay
    cumulativePriceVolume := hl2 * volume
    cumulativeVolume := volume
    cumulativePriceSquaredVolume := volume * hl2 * hl2
else
    cumulativePriceVolume += hl2 * volume
    cumulativeVolume += volume
    cumulativePriceSquaredVolume += volume * hl2 * hl2

sessionVWAP = cumulativeVolume > 0.0
     ? cumulativePriceVolume / cumulativeVolume
     : na

variance = cumulativeVolume > 0.0
     ? cumulativePriceSquaredVolume / cumulativeVolume -
       sessionVWAP * sessionVWAP
     : na

standardDeviation = math.sqrt(math.max(nz(variance), 0.0))

upperBand = sessionVWAP + upperDeviation * standardDeviation
lowerBand = sessionVWAP - lowerDeviation * standardDeviation

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FAST DIVERGENCE REFERENCE POINTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float bearReferencePrice = na
var float bearReferenceRSI = na
var int bearReferenceBar = na

var float bullReferencePrice = na
var float bullReferenceRSI = na
var int bullReferenceBar = na

// Reset bearish reference after RSI leaves the upper regime.
if rsiValue < bearReset
    bearReferencePrice := na
    bearReferenceRSI := na
    bearReferenceBar := na

// Reset bullish reference after RSI leaves the lower regime.
if rsiValue > bullReset
    bullReferencePrice := na
    bullReferenceRSI := na
    bullReferenceBar := na

// Expire references that are too old.
if not na(bearReferenceBar) and bar_index - bearReferenceBar > lookbackBars
    bearReferencePrice := na
    bearReferenceRSI := na
    bearReferenceBar := na

if not na(bullReferenceBar) and bar_index - bullReferenceBar > lookbackBars
    bullReferencePrice := na
    bullReferenceRSI := na
    bullReferenceBar := na

// Create the initial overbought reference.
newBearReference =
     rsiValue > overbought and
     (
         na(bearReferenceRSI) or
         rsiValue > bearReferenceRSI
     )

// Create the initial oversold reference.
newBullReference =
     rsiValue < oversold and
     (
         na(bullReferenceRSI) or
         rsiValue < bullReferenceRSI
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIVERGENCE MEASUREMENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bearPriceExtension =
     not na(bearReferencePrice) and bearReferencePrice != 0.0
     ? (bearPriceSource / bearReferencePrice - 1.0) * 100.0
     : na

bullPriceExtension =
     not na(bullReferencePrice) and bullReferencePrice != 0.0
     ? (bullReferencePrice / bullPriceSource - 1.0) * 100.0
     : na

bearRsiDifference =
     not na(bearReferenceRSI)
     ? bearReferenceRSI - rsiValue
     : na

bullRsiDifference =
     not na(bullReferenceRSI)
     ? rsiValue - bullReferenceRSI
     : na

bearRsiTurn =
     not requireRsiTurn or
     rsiValue <= rsiValue[1]

bullRsiTurn =
     not requireRsiTurn or
     rsiValue >= rsiValue[1]

bearishCandleConfirmation =
     not requireCandleDirection or
     close < open

bullishCandleConfirmation =
     not requireCandleDirection or
     close > open

// Bearish divergence:
// Price forms a higher high while RSI forms a lower high.
fastBearDivergence =
     not na(bearReferencePrice) and
     not na(bearReferenceRSI) and
     bearPriceSource > bearReferencePrice and
     bearPriceExtension >= minimumPriceExtension and
     bearRsiDifference >= minimumRsiDifference and
     bearRsiTurn and
     bearishCandleConfirmation

// Bullish divergence:
// Price forms a lower low while RSI forms a higher low.
fastBullDivergence =
     not na(bullReferencePrice) and
     not na(bullReferenceRSI) and
     bullPriceSource < bullReferencePrice and
     bullPriceExtension >= minimumPriceExtension and
     bullRsiDifference >= minimumRsiDifference and
     bullRsiTurn and
     bullishCandleConfirmation

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP VALIDATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bearVWAPTouch =
     vwapValidationMode == "Wick Touch"
     ? high >= upperBand
     : close >= upperBand

bullVWAPTouch =
     vwapValidationMode == "Wick Touch"
     ? low <= lowerBand
     : close <= lowerBand

bearVWAPConfirmed =
     not useVWAPFilter or
     bearVWAPTouch

bullVWAPConfirmed =
     not useVWAPFilter or
     bullVWAPTouch

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLOSE CONFIRMATION AND DUPLICATE CONTROL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

candleIsConfirmed =
     not confirmAtClose or
     barstate.isconfirmed

var int lastBuyBar = na
var int lastSellBar = na

buyCooldownPassed =
     na(lastBuyBar) or
     bar_index - lastBuyBar > cooldownBars

sellCooldownPassed =
     na(lastSellBar) or
     bar_index - lastSellBar > cooldownBars

buySignal =
     candleIsConfirmed and
     fastBullDivergence and
     bullVWAPConfirmed and
     buyCooldownPassed

sellSignal =
     candleIsConfirmed and
     fastBearDivergence and
     bearVWAPConfirmed and
     sellCooldownPassed

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE REFERENCES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// After a signal, make the signal candle the new comparison point.
// This prevents the same divergence from printing repeatedly.
if buySignal
    lastBuyBar := bar_index
    bullReferencePrice := bullPriceSource
    bullReferenceRSI := rsiValue
    bullReferenceBar := bar_index
else if newBullReference
    bullReferencePrice := bullPriceSource
    bullReferenceRSI := rsiValue
    bullReferenceBar := bar_index

if sellSignal
    lastSellBar := bar_index
    bearReferencePrice := bearPriceSource
    bearReferenceRSI := rsiValue
    bearReferenceBar := bar_index
else if newBearReference
    bearReferencePrice := bearPriceSource
    bearReferenceRSI := rsiValue
    bearReferenceBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     showVWAP ? sessionVWAP : na,
     "Session VWAP",
     color = color.yellow,
     linewidth = 2
)

upperPlot = plot(
     showBands ? upperBand : na,
     "Upper VWAP Deviation",
     color = color.new(color.red, 35),
     linewidth = 1
)

lowerPlot = plot(
     showBands ? lowerBand : na,
     "Lower VWAP Deviation",
     color = color.new(color.green, 35),
     linewidth = 1
)

vwapPlot = plot(
     showBands ? sessionVWAP : na,
     "VWAP Fill Reference",
     color = color.new(color.gray, 100)
)

fill(
     upperPlot,
     vwapPlot,
     color = color.new(color.red, 93)
)

fill(
     lowerPlot,
     vwapPlot,
     color = color.new(color.green, 93)
)

plotshape(
     showDivergenceMarkers and buySignal,
     title = "BUY",
     text = "BUY",
     location = location.belowbar,
     style = shape.labelup,
     size = size.tiny,
     color = color.lime,
     textcolor = color.black
)

plotshape(
     showDivergenceMarkers and sellSignal,
     title = "SELL",
     text = "SELL",
     location = location.abovebar,
     style = shape.labeldown,
     size = size.tiny,
     color = color.red,
     textcolor = color.white
)

plotshape(
     showReferencePoints and newBullReference,
     title = "Bull Reference",
     location = location.belowbar,
     style = shape.circle,
     size = size.tiny,
     color = color.new(color.green, 45)
)

plotshape(
     showReferencePoints and newBearReference,
     title = "Bear Reference",
     location = location.abovebar,
     style = shape.circle,
     size = size.tiny,
     color = color.new(color.red, 45)
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buySignal,
     title = "Fast RSI Divergence BUY",
     message = "BUY: Bullish RSI divergence confirmed near the lower VWAP deviation band."
)

alertcondition(
     sellSignal,
     title = "Fast RSI Divergence SELL",
     message = "SELL: Bearish RSI divergence confirmed near the upper VWAP deviation band."
)
````
