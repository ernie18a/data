# Engulfing Candles with Filters

- url: https://www.tradingview.com/script/m0oLlYQ1-Engulfing-Candles-with-Filters/
- type: indicator
- pine_id: PUB;598ee8fd4240489b8ff5608169dd0bc0
- version: 2.0

## Description

// =============================================================================
// ENGULFING CANDLES WITH FILTERS — Pine Script v6
// =============================================================================
//
// WHAT IT DOES
//   Detects bullish/bearish engulfing patterns with three optional filters:
//     - ATR body filter        : engulfing candle body ≥ bodyMult × ATR
//     - Prior-body floor       : engulfed candle body  ≥ priorMult × ATR
//     - Volume confirmation    : volume > volume[1]
//   Each filter has its own on/off toggle. Disabled = ignored (always passes).
//
// QUICK SETUP
//   1. Paste into TradingView Pine Editor → Save → Add to chart
//   2. Open gear icon on indicator legend to toggle filters / adjust parameters
//   3. Triangles plot on signals; alertconditions wired for both directions
//
// DEFAULT SETTINGS
//   ATR(14), bodyMult 1.0, priorMult 0.3, volume filter ON
//   Good starting point for 1H–4H on liquid equities/futures/crypto.
//   On FX: disable volume filter (TV volume = broker tick count, not real flow).
//
// STRATEGY / BACKTEST MODE
//   1. Comment out the indicator(...) line
//   2. Uncomment the strategy(...) line
//   3. Uncomment the two if/strategy.entry/exit blocks at bottom
//   4. Set From/To date inputs; replace placeholder qty/profit/loss values
//
// FILTER TUNING WORKFLOW
//   Disable all filters first → baseline signal count.
//   Enable one at a time to isolate each filter's effect on hit rate.
//   Don't trust combined-filter results without per-filter attribution.
//
// CAVEATS
//   - Engulfing patterns are regime-dependent; stratify results by ADX/RV.
//   - Strategy block defaults (qty=25000, profit=1000, loss=50) are placeholders.
//   - No explicit prior-candle color check; priorMult filter is the proxy.
//
// =============================================================================

## Source Code

````pine
//@version=6
indicator("Engulfing Candles with Filters", overlay=true)
// strategy("Engulfing Candles with Filters", overlay=true) // uncomment for backtesting

// === FILTER INPUTS ===
useATR    = input.bool(true,  title="Enable ATR body filter")
atrLen    = input.int(14,     title="ATR Length",              minval=1)
bodyMult  = input.float(1.0,  title="Engulfing Body ≥ x ATR",  minval=0.0, step=0.1)
usePrior  = input.bool(true,  title="Enable prior-body floor")
priorMult = input.float(0.3,  title="Prior Body Floor ≥ x ATR", minval=0.0, step=0.1)
useVolume = input.bool(true,  title="Require volume > previous bar")
useTrend  = input.bool(true,  title="Enable trend filter")
trendLen  = input.int(50,     title="Trend MA Length",         minval=1)

// === BAR REFERENCES ===
openBarPrevious  = open[1]
closeBarPrevious = close[1]
openBarCurrent   = open
closeBarCurrent  = close

// === FILTERS ===
atrVal       = ta.atr(atrLen)
bodyCurrent  = math.abs(closeBarCurrent  - openBarCurrent)
bodyPrevious = math.abs(closeBarPrevious - openBarPrevious)

bodyFilter   = not useATR    or bodyCurrent  >= atrVal * bodyMult
priorFilter  = not usePrior  or bodyPrevious >= atrVal * priorMult
volumeFilter = not useVolume or volume > volume[1]

// Trend filter — directional. Evaluated on prior bar to avoid look-ahead from
// the engulfing bar's own close flipping the MA relationship.
trendMA         = ta.ema(close, trendLen)
downtrend       = close[1] < trendMA[1] and trendMA < trendMA[5]
uptrend         = close[1] > trendMA[1] and trendMA > trendMA[5]
trendFilterBull = not useTrend or downtrend
trendFilterBear = not useTrend or uptrend

// === PATTERN LOGIC ===
bullishEngulfing = (openBarCurrent <= closeBarPrevious) and (openBarCurrent < openBarPrevious) and (closeBarCurrent > openBarPrevious) and bodyFilter and priorFilter and volumeFilter and trendFilterBull
bearishEngulfing = (openBarCurrent >= closeBarPrevious) and (openBarCurrent > openBarPrevious) and (closeBarCurrent < openBarPrevious) and bodyFilter and priorFilter and volumeFilter and trendFilterBear

// === PLOTS ===
plotshape(bullishEngulfing, style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.tiny)
plotshape(bearishEngulfing, style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.tiny)

// Optional: plot trend MA for visual confirmation (comment out if noisy)
plot(trendMA, title="Trend MA", color=color.new(color.blue, 60))

// === ALERTS ===
alertcondition(bullishEngulfing, title="Bullish Engulfing", message="[CurrencyPair] [TimeFrame], Bullish candle engulfing previous candle")
alertcondition(bearishEngulfing, title="Bearish Engulfing", message="[CurrencyPair] [TimeFrame], Bearish candle engulfing previous candle")

//================================BACKTEST================================//

// === INPUT BACKTEST RANGE ===
FromMonth = input.int(1,    title="From Month", minval=1, maxval=12)
FromDay   = input.int(1,    title="From Day",   minval=1, maxval=31)
FromYear  = input.int(2017, title="From Year",  minval=2017)
ToMonth   = input.int(1,    title="To Month",   minval=1, maxval=12)
ToDay     = input.int(1,    title="To Day",     minval=1, maxval=31)
ToYear    = input.int(9999, title="To Year",    minval=2017)

start    = timestamp(FromYear, FromMonth, FromDay,  0,  0)
finish   = timestamp(ToYear,   ToMonth,   ToDay,   23, 59)
inWindow = time >= start and time <= finish

// === EXECUTION === // Uncomment the strategy() line above and this block when backtesting
// if bullishEngulfing and inWindow
//     strategy.entry("L", strategy.long, qty=25000)
//     strategy.exit("exit L", "L", profit=1000, loss=50)

// if bearishEngulfing and inWindow
//     strategy.entry("S", strategy.short, qty=25000)
//     strategy.exit("exit S", "S", profit=1000, loss=50)
````
