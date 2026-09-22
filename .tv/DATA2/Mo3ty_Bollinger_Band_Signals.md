<!-- tradingview-pine-id: PUB;5c2181945ee144789e4a4e01fd9a9ea5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Mo3ty Bollinger Band Signals

Source: https://www.tradingview.com/script/aOcW8hza-Mo3ty-Bollinger-Band-Signals/

## Description

# Mo3ty Bollinger Band Signals

**Mo3ty Bollinger Band Signals** is a technical analysis indicator designed to identify potential Bollinger Band re-entry setups and refine them using candle-based confirmation filters.

The indicator focuses on price returning inside the Bollinger Bands after a previous candle has closed outside the band. Additional confirmation filters can be enabled or disabled independently to help users evaluate the quality of each setup.

## Core Signal Logic

### BUY Signal

A BUY setup occurs when:

1. The previous candle closes below the Lower Bollinger Band.
2. The current candle opens inside the Bollinger Band range.
3. The current candle closes inside the Bollinger Band range.
4. Optional confirmation filters are satisfied.

### SELL Signal

A SELL setup occurs when:

1. The previous candle closes above the Upper Bollinger Band.
2. The current candle opens inside the Bollinger Band range.
3. The current candle closes inside the Bollinger Band range.
4. Optional confirmation filters are satisfied.

## Confirmation Filters

The indicator includes several optional filters that can be independently enabled or disabled:

**Candle Direction Confirmation**
Requires the candle to move in the expected direction:

* BUY: bullish candle
* SELL: bearish candle

**Minimum Candle Body Strength**
Measures the candle body relative to its total high-low range. Users can define the minimum percentage required for a signal.

**Close Position Confirmation**
Evaluates where the candle closes within its own range:

* BUY setups favor closes toward the upper portion of the candle.
* SELL setups favor closes toward the lower portion.

These filters are designed to make the signal logic more selective while allowing users to customize the indicator according to their own analysis.

## Default Settings

* Bollinger Band Length: **50**
* Standard Deviation: **2.0**
* Confirmation filters: **Enabled by default**
* Signals are evaluated only after candle confirmation.

All major parameters can be adjusted from the indicator settings.

## Alerts

The indicator provides separate alert conditions for:

* BUY Signal
* SELL Signal

Users can create TradingView alerts based on these conditions.

## Important Notes

Mo3ty Bollinger Band Signals is a technical analysis tool intended to assist with market analysis and does not provide guaranteed trading results.

Signals should be evaluated together with market structure, volatility, timeframe, risk management, and other relevant factors.

The indicator does not use future data or intentionally rely on unconfirmed bars for generating completed signals.

**Designed for educational and technical analysis purposes.**

---

## Source Code

````pine
//@version=6
indicator("Mo3ty Bollinger Band Signals", shorttitle="Mo3ty BB Signals", overlay=true)

//────────────────────────────────────
// Bollinger Band Settings
//────────────────────────────────────
groupBB = "Bollinger Bands"

bbLength = input.int(
     50,
     "BB Length",
     minval=1,
     group=groupBB
)

bbMultiplier = input.float(
     2.0,
     "Standard Deviation",
     minval=0.1,
     step=0.1,
     group=groupBB
)

showBands = input.bool(
     true,
     "Show Bollinger Bands",
     group=groupBB
)

//────────────────────────────────────
// Confirmation Filters
//────────────────────────────────────
groupFilters = "Signal Confirmation Filters"

useDirectionFilter = input.bool(
     true,
     "Candle Direction Confirmation",
     group=groupFilters
)

useBodyFilter = input.bool(
     true,
     "Minimum Candle Body Strength",
     group=groupFilters
)

minBodyStrength = input.float(
     50.0,
     "Minimum Body Strength (%)",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=groupFilters
)

useClosePositionFilter = input.bool(
     true,
     "Close Position Confirmation",
     group=groupFilters
)

closePositionThreshold = input.float(
     50.0,
     "Close Position Threshold (%)",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=groupFilters
)

//────────────────────────────────────
// Signal Display
//────────────────────────────────────
groupDisplay = "Signal Display"

showBuySignals = input.bool(
     true,
     "Show BUY Signals",
     group=groupDisplay
)

showSellSignals = input.bool(
     true,
     "Show SELL Signals",
     group=groupDisplay
)

//────────────────────────────────────
// Bollinger Band Calculation
//────────────────────────────────────
basis = ta.sma(close, bbLength)
deviation = bbMultiplier * ta.stdev(close, bbLength)

upperBand = basis + deviation
lowerBand = basis - deviation

//────────────────────────────────────
// Plot Bollinger Bands
//────────────────────────────────────
plotBasis = plot(
     showBands ? basis : na,
     title="BB Basis",
     linewidth=1
)

plotUpper = plot(
     showBands ? upperBand : na,
     title="BB Upper",
     linewidth=1
)

plotLower = plot(
     showBands ? lowerBand : na,
     title="BB Lower",
     linewidth=1
)

fill(
     plotUpper,
     plotLower,
     title="Bollinger Band Range"
)

//────────────────────────────────────
// Current Candle Calculations
//────────────────────────────────────
candleRange = high - low
candleBody = math.abs(close - open)

bodyStrength = candleRange > 0
     ? (candleBody / candleRange) * 100.0
     : 0.0

closePosition = candleRange > 0
     ? ((close - low) / candleRange) * 100.0
     : 50.0

//────────────────────────────────────
// Core Re-Entry Logic
//────────────────────────────────────

// Previous candle closed outside the band
previousBelowLower = close[1] < lowerBand[1]
previousAboveUpper = close[1] > upperBand[1]

// Current candle opens and closes inside the Bollinger Band range
currentOpenInside =
     open >= lowerBand and
     open <= upperBand

currentCloseInside =
     close >= lowerBand and
     close <= upperBand

currentCandleInside =
     currentOpenInside and
     currentCloseInside

//────────────────────────────────────
// Confirmation Filters
//────────────────────────────────────

// Candle direction
buyDirectionOK =
     not useDirectionFilter or close > open

sellDirectionOK =
     not useDirectionFilter or close < open

// Candle body strength
buyBodyOK =
     not useBodyFilter or bodyStrength >= minBodyStrength

sellBodyOK =
     not useBodyFilter or bodyStrength >= minBodyStrength

// Close position inside candle
buyClosePositionOK =
     not useClosePositionFilter or
     closePosition >= closePositionThreshold

sellClosePositionOK =
     not useClosePositionFilter or
     closePosition <= (100.0 - closePositionThreshold)

//────────────────────────────────────
// Final Signal Conditions
//────────────────────────────────────

buySignal =
     barstate.isconfirmed and
     previousBelowLower and
     currentCandleInside and
     buyDirectionOK and
     buyBodyOK and
     buyClosePositionOK

sellSignal =
     barstate.isconfirmed and
     previousAboveUpper and
     currentCandleInside and
     sellDirectionOK and
     sellBodyOK and
     sellClosePositionOK

//────────────────────────────────────
// BUY / SELL Plot
//────────────────────────────────────

plotshape(
     showBuySignals and buySignal,
     title="BUY Signal",
     style=shape.labelup,
     location=location.belowbar,
     text="BUY",
     textcolor=color.white,
     size=size.small,
     color=color.green
)

plotshape(
     showSellSignals and sellSignal,
     title="SELL Signal",
     style=shape.labeldown,
     location=location.abovebar,
     text="SELL",
     textcolor=color.white,
     size=size.small,
     color=color.red
)

//────────────────────────────────────
// Alerts
//────────────────────────────────────

alertcondition(
     buySignal,
     title="Mo3ty BB BUY",
     message="Mo3ty Bollinger Band Signals: BUY signal confirmed."
)

alertcondition(
     sellSignal,
     title="Mo3ty BB SELL",
     message="Mo3ty Bollinger Band Signals: SELL signal confirmed."
)
````
