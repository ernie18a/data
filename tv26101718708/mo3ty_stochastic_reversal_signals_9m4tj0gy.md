# Mo3ty Stochastic Reversal Signals

- url: https://www.tradingview.com/script/9M4tJ0Gy-Mo3ty-Stochastic-Reversal-Signals/
- type: indicator
- pine_id: PUB;af487f759fe34fcab9c7cf414f8a3ef9
- version: 1.0

## Description

Mo3ty Stochastic Reversal Signals is a rule-based indicator designed to identify potential bullish and bearish reversal signals using a smoothed Stochastic K calculation, optional EMA trend filtering, candle-close confirmation, and a same-signal cooldown mechanism.

HOW IT WORKS

The indicator calculates a smoothed Stochastic K using the following default settings:

- K Length: 21
- K Smoothing: 5
- Overbought: 80
- Oversold: 20

The D line is intentionally not used in the signal logic.

BUY SIGNAL

A BUY signal requires:

- The previous Stochastic K value to be at or below the Oversold level.
- The current Stochastic K to turn upward relative to the previous value.
- Price to be above the selected EMA when the EMA filter is enabled.
- The current candle close to be higher than the previous candle close when candle confirmation is enabled.
- The candle must be confirmed/closed.
- The BUY signal must be re-armed after Stochastic exits the Oversold area.
- The same-signal cooldown must be satisfied.

SELL SIGNAL

A SELL signal requires:

- The previous Stochastic K value to be at or above the Overbought level.
- The current Stochastic K to turn downward relative to the previous value.
- Price to be below the selected EMA when the EMA filter is enabled.
- The current candle close to be lower than the previous candle close when candle confirmation is enabled.
- The candle must be confirmed/closed.
- The SELL signal must be re-armed after Stochastic exits the Overbought area.
- The same-signal cooldown must be satisfied.

EMA FILTER

The EMA filter can be enabled or disabled.

The EMA length is fully adjustable by the user and defaults to 50.

SIGNAL COOLDOWN

To reduce repeated signals of the same type, the indicator includes an adjustable same-signal cooldown.

The default setting is 5 bars.

For example, after a SELL signal, another SELL signal cannot be generated until the configured number of bars has elapsed and all other signal conditions are satisfied.

CONFIRMATION AND SIGNAL BEHAVIOR

Signals are generated only on confirmed candle closes.

The script does not use future-looking data or lookahead calculations for its signal generation.

The indicator is designed to provide rule-based signals for chart analysis. Signals should be evaluated together with market conditions, timeframe, volatility, and the user's own risk management.

ALERTS

The indicator includes separate alert conditions for:

- BUY
- SELL

Users can create TradingView alerts based on these conditions.

IMPORTANT

This indicator is an analytical tool and does not guarantee profitable results. Historical signals do not guarantee future performance. Users should perform their own analysis and apply appropriate risk management.

## Source Code

````pine
//@version=6
indicator("Mo3ty Stochastic Reversal Signals", shorttitle="Mo3ty Stoch Signals", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

kLength = input.int(21, "Stochastic K Length", minval=1)
kSmooth = input.int(5, "K Smoothing", minval=1)

overbought = input.float(80.0, "Overbought Level", minval=50.0, maxval=100.0)
oversold   = input.float(20.0, "Oversold Level", minval=0.0, maxval=50.0)

useEMA    = input.bool(true, "Use EMA Filter")
emaLength = input.int(50, "EMA Length", minval=1)

useCandleFilter = input.bool(true, "Use Candle Confirmation")

// Minimum number of closed candles between
// two signals of the SAME type
signalCooldown = input.int(5, "Same Signal Cooldown (Bars)", minval=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOCHASTIC CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

lowestLow   = ta.lowest(low, kLength)
highestHigh = ta.highest(high, kLength)

priceRange = highestHigh - lowestLow

rawK = priceRange != 0 ?
     100.0 * (close - lowestLow) / priceRange :
     0.0

// K only — D% intentionally removed
k = ta.sma(rawK, kSmooth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaValue = ta.ema(close, emaLength)

plot(
     emaValue,
     title="EMA",
     color=color.orange,
     linewidth=2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOCHASTIC REVERSAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// BUY:
// Previous bar was in Oversold
// Current bar shows K turning upward

stochBuy =
     k[1] <= oversold and
     k > k[1]

// SELL:
// Previous bar was in Overbought
// Current bar shows K turning downward

stochSell =
     k[1] >= overbought and
     k < k[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullishCandle = close > close[1]
bearishCandle = close < close[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buyEMACondition =
     not useEMA or close > emaValue

sellEMACondition =
     not useEMA or close < emaValue

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LOCK SYSTEM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool buyArmed  = true
var bool sellArmed = true

// Store the bar where the last BUY/SELL occurred
var int lastBuyBar  = na
var int lastSellBar = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RE-ARM LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// BUY becomes available again only after
// Stochastic exits Oversold.

if barstate.isconfirmed and k > oversold
    buyArmed := true

// SELL becomes available again only after
// Stochastic exits Overbought.

if barstate.isconfirmed and k < overbought
    sellArmed := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAME SIGNAL COOLDOWN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// BUY cooldown
buyCooldownOK =
     na(lastBuyBar) or
     (bar_index - lastBuyBar > signalCooldown)

// SELL cooldown
sellCooldownOK =
     na(lastSellBar) or
     (bar_index - lastSellBar > signalCooldown)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL SETUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buySetup =
     stochBuy and
     buyEMACondition and
     (not useCandleFilter or bullishCandle)

sellSetup =
     stochSell and
     sellEMACondition and
     (not useCandleFilter or bearishCandle)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONFIRMED SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

confirmedBuy =
     barstate.isconfirmed and
     buySetup and
     buyArmed and
     buyCooldownOK

confirmedSell =
     barstate.isconfirmed and
     sellSetup and
     sellArmed and
     sellCooldownOK

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOCK + RECORD SIGNAL BAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if confirmedBuy
    buyArmed := false
    lastBuyBar := bar_index

if confirmedSell
    sellArmed := false
    lastSellBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     confirmedBuy,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small
)

plotshape(
     confirmedSell,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     confirmedBuy,
     title="Mo3ty BUY Signal",
     message="Mo3ty Stochastic Reversal Signals: BUY confirmed on candle close."
)

alertcondition(
     confirmedSell,
     title="Mo3ty SELL Signal",
     message="Mo3ty Stochastic Reversal Signals: SELL confirmed on candle close."
)
````
