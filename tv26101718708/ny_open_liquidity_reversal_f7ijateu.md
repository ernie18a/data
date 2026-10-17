# NY Open Liquidity Reversal

- url: https://www.tradingview.com/script/f7iJaTeU-NY-Open-Liquidity-Reversal/
- type: indicator
- pine_id: PUB;2acb032c35a8495da47226b875b358d7
- version: 1.0

## Description

Detects Liquidity Reversal during the New York session for the first 90 minutes of market opening.

## Source Code

````pine
//@version=6
indicator("NY Open Liquidity Reversal", overlay=true)

// =====================================================
// SESSION SETTINGS
// =====================================================

nySession = input.session("0930-1100", "NY Session")
rangeSession = input.session("0930-0945", "Opening Range")

inSession = not na(time(timeframe.period, nySession, "America/New_York"))
inRangeSession = not na(time(timeframe.period, rangeSession, "America/New_York"))

// =====================================================
// OPENING RANGE
// =====================================================

var float rangeHigh = na
var float rangeLow = na

// Reset daily
newDay = ta.change(dayofmonth) != 0

if newDay
    rangeHigh := na
    rangeLow := na

if inRangeSession
    rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
    rangeLow := na(rangeLow) ? low : math.min(rangeLow, low)

plot(rangeHigh, color=color.green, linewidth=2, title="Range High")
plot(rangeLow, color=color.red, linewidth=2, title="Range Low")

// =====================================================
// BREAKOUT CONDITIONS
// =====================================================

buyBreakout = not na(rangeLow) and close < rangeLow
sellBreakout = not na(rangeHigh) and close > rangeHigh

// =====================================================
// REVERSAL CANDLES
// =====================================================

// Bullish Engulfing
bullEngulf = (
    close > open and
    close[1] < open[1] and
    close > open[1] and
    open < close[1]
)

// Bearish Engulfing
bearEngulf = (
    close < open and
    close[1] > open[1] and
    close < open[1] and
    open > close[1]
)

// Hammer
hammer = (
    close > open and
    (low < open - (close - open) * 2)
)

// Shooting Star
shootingStar = (
    close < open and
    (high > open + (open - close) * 2)
)
// =====================================================
// STATE MANAGEMENT
// =====================================================

var bool buySetup = false
var bool sellSetup = false
var bool signalTriggered = false

if newDay
    buySetup := false
    sellSetup := false
    signalTriggered := false

// BUY SETUP ACTIVATION
if buyBreakout and inSession and not signalTriggered
    buySetup := true

// SELL SETUP ACTIVATION
if sellBreakout and inSession and not signalTriggered
    sellSetup := true

// =====================================================
// INVALIDATION
// =====================================================

// Cancel BUY if price returns inside range
if buySetup and close > rangeLow
    buySetup := false

// Cancel SELL if price returns inside range
if sellSetup and close < rangeHigh
    sellSetup := false

// =====================================================
// ENTRY SIGNALS
// =====================================================

buySignal =
     buySetup and
     (bullEngulf or hammer) and
     barstate.isconfirmed

sellSignal =
     sellSetup and
     (bearEngulf or shootingStar) and
     barstate.isconfirmed
// Trigger only first signal
if buySignal or sellSignal
    signalTriggered := true

// =====================================================
// PLOTS
// =====================================================

plotshape(
     buySignal,
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY"
)

plotshape(
     sellSignal,
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL"
)

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     buySignal,
     title="BUY ALERT",
     message="NY Open BUY Setup"
)

alertcondition(
     sellSignal,
     title="SELL ALERT",
     message="NY Open SELL Setup"
)
````
