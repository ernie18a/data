# Trend Pulse OBV

- url: https://www.tradingview.com/script/LBcj22se-Trend-Pulse-OBV/
- type: strategy
- pine_id: PUB;6ce04ee1c0354ccca19d20fa91e44397
- version: 1.0

## Description

Trend Pulse OBV Strategy

Trend Pulse OBV is an educational long-only strategy designed to study trend-channel breakouts that are confirmed by volume flow and a higher-level regime filter.

The strategy combines three main ideas:

1. A Trend Pulse Channel breakout.
2. OBV confirmation using On-Balance Volume relative to its EMA.
3. A regime filter using price relative to an EMA.

The purpose of the script is to test whether upside breakouts above an adaptive channel are more selective when confirmed by both volume accumulation and broader trend direction.

This is a strategy script for research, backtesting, and forward-testing only. It is not financial advice, does not predict future price movement, and does not guarantee profitable results. Historical strategy results are hypothetical and can differ significantly from live trading because of slippage, commissions, liquidity, spread, execution quality, timeframe selection, and market regime changes.

Core concept

The strategy is built around a Trend Pulse Channel. The channel uses a smoothed filter based on the selected source price and a filtered true-range calculation to create an upper breakout band.

A long entry can occur when price crosses above the Trend Pulse Channel upper band, but only if the selected confirmation filters are satisfied.

The strategy does not open short positions.

Entry logic

A long entry occurs when all selected conditions are satisfied:

* Price crosses above the Trend Pulse Channel upper band.
* Price is within the selected date range.
* The regime filter is satisfied, if enabled.
* The OBV confirmation filter is satisfied, if enabled.
* No long position is already open.

The strategy is designed to avoid entering every channel breakout. Instead, it requires confirmation that price is breaking out while broader trend and volume conditions support the move.

Trend Pulse Channel

The Trend Pulse Channel is calculated from:

* A selected source price, default HLC3.
* A multi-pole smoothing filter.
* A filtered true-range stream.
* A range multiplier used to define the upper band.

The upper channel band is used as the breakout trigger.

The midline is used as a possible exit reference when the midline exit is enabled.

OBV confirmation filter

The OBV filter compares On-Balance Volume to an EMA of OBV.

When the filter is enabled, long entries are allowed only when OBV is above its EMA. This is intended to require evidence that volume flow supports the upside breakout.

This does not guarantee continuation. It only adds a volume-based confirmation condition to the channel breakout.

Regime filter

The regime filter compares price to a selected EMA.

When enabled, long entries require price to be above the regime EMA. This is intended to reduce long entries during weaker or downward market environments.

The regime EMA can also be used as an exit condition if the regime exit is enabled.

Lag Mode

Lag Mode applies a zero-lag style pre-transform to both the price source and the true-range stream before they are filtered.

This can make the Trend Pulse Channel respond faster to new price movement, but it can also increase sensitivity and may create more false signals in choppy markets.

Exit logic

The strategy has multiple exit mechanisms:

1. ATR stop

At entry, the script calculates a fixed stop price using the previous bar’s ATR multiplied by the selected ATR stop multiplier. This stop remains fixed after entry.

2. Midline exit

When enabled, the strategy exits if price closes below the Trend Pulse Channel midline.

3. Regime EMA exit

When enabled, the strategy exits if price closes below the regime EMA.

The first active exit condition to trigger can close the position.

Risk and position sizing

The default strategy uses percent-of-equity position sizing.

Users should review the default order size carefully before publishing or relying on backtest results. A large percent-of-equity allocation can make historical results look stronger or weaker than they would under more conservative risk assumptions.

For public publication, users should use realistic position sizing, commission, and slippage assumptions that match the market being tested.

Default strategy properties

The script uses the following strategy properties:

* Initial capital: 1,000
* Position sizing: percent of equity
* Default order size: 70% of equity
* Commission: 0.1%
* Slippage: defined in the strategy settings
* Pyramiding: 1
* Fill orders on standard OHLC: enabled
* Calculate on every tick: disabled
* Calculate on order fills: disabled
* Bar magnifier: disabled
* Process orders on close: disabled
* Long-only execution

These values are provided for testing and can be changed by the user. They should not be interpreted as recommended risk settings.

Important backtesting note

TradingView strategy results are simulations based on historical chart data. They are not live trading results.

Backtest results can change significantly depending on:

* Symbol.
* Timeframe.
* Date range.
* Liquidity.
* Spread.
* Commission.
* Slippage.
* Position size.
* Trend Pulse period.
* Number of poles.
* Range multiplier.
* Lag Mode setting.
* OBV EMA length.
* Regime EMA length.
* ATR length.
* ATR stop multiplier.
* Exit settings.
* Market regime.

Users should test the strategy on a sufficiently large number of trades and across different market conditions before drawing conclusions. A small sample of trades is not enough to evaluate a strategy reliably.

How to use it

A practical workflow is:

1. Select the symbol and timeframe to test.
2. Use a realistic date range that includes different market regimes.
3. Confirm that the strategy produces a sufficient number of trades.
4. Adjust commission and slippage to reflect the market being tested.
5. Review whether the percent-of-equity order size is suitable.
6. Compare results with the OBV filter on and off.
7. Compare results with the regime filter on and off.
8. Compare exits using the midline exit, regime exit, and ATR stop behavior.
9. Forward-test before considering any real-world use.

Inputs

Date Range

* Start Date: first date included in the backtest.
* End Date: last date included in the backtest.

Trend Pulse Channel

* Source: price source used in the channel calculation.
* Poles: smoothing pole count used by the filter.
* Period: main channel smoothing period.
* Range Multiplier: controls the distance of the upper channel band.
* Lag Mode: applies the zero-lag pre-transform before filtering.

OBV Confirmation Filter

* Require OBV > EMA(OBV, N): enables or disables OBV confirmation.
* OBV EMA Length: EMA length applied to OBV.

Regime Filter

* Require close > regime EMA: enables or disables the regime filter.
* Regime EMA Length: EMA length used for the regime filter.

Exit Logic

* Exit on close < TPC midline: exits when price closes below the channel midline.
* Exit on close < regime EMA: exits when price closes below the regime EMA.

Risk — ATR Stop

* ATR Length: ATR period used for stop calculation.
* ATR Stop Multiplier: ATR multiplier used to set the fixed stop distance at entry.

Visual elements

The strategy plots:

* Trend Pulse Channel upper band.
* Trend Pulse Channel midline.
* Regime EMA.
* Long entry markers.
* Long exit markers.

Limitations

This strategy is long-only and does not evaluate short trades.

The strategy can underperform during sideways, choppy, low-volume, or news-driven conditions.

OBV confirmation can reduce some weak breakouts, but it cannot eliminate false breakouts.

The regime EMA is a lagging trend filter and may delay entries or exits.

The ATR stop is fixed at entry and may not adapt to changing volatility after the trade opens.

A breakout above the channel does not guarantee trend continuation.

No backtest can guarantee future performance.

Recommended use

Trend Pulse OBV is used as an educational framework for studying channel breakout behavior with volume-flow confirmation and regime filtering.

It should be used with realistic backtesting assumptions, conservative position sizing, and independent validation before any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0
/// © ADXAE

//@version=6
// =============================================================================
//  Trend Pulse OBV Strategy
// -----------------------------------------------------------------------------

strategy(title                       = "Trend Pulse OBV",
         overlay                     = true,
         initial_capital             = 1000,
         default_qty_type            = strategy.percent_of_equity,
         default_qty_value           = 33,
         commission_type             = strategy.commission.percent,
         commission_value            = 0.1,
         slippage                    = 1,
         margin_long                 = 0,
         margin_short                = 0,
         fill_orders_on_standard_ohlc= true,
         calc_on_every_tick          = false,
         calc_on_order_fills         = false,
         use_bar_magnifier           = false,
         process_orders_on_close     = false,
         pyramiding                  = 1)

// ──────────────────────── User inputs ────────────────────────
startDate = input.time(timestamp("1 Jan 2018 00:00 +0000"), "Start Date",
         tooltip = "First bar on which new entries and forced exits can fire. Indicators still warm up on earlier bars so signals are stable when trading begins.")
endDate   = input.time(timestamp("31 Dec 2069 23:59 +0000"), "End Date",
         tooltip = "Last bar on which new entries can fire. Leave far in the future to run to the current bar.")
inRange   = time >= startDate and time <= endDate

grpT = "Trend Pulse Channel (core)"
tpcSrc   = input.source(hlc3, "Source", group = grpT,
         tooltip = "Price source fed into the Gaussian filter. hlc3 is the Trend Pulse default and smooths intraday noise vs. close-only.")
tpcPoles = input.int(4, "Poles", minval = 1, maxval = 4, group = grpT,
         tooltip = "Cascaded-EMA pole count. Higher = smoother but more lag. The Pine implementation hardcodes a ceiling of 4 to match the canonical indicator.")
tpcPeriod= input.int(144, "Period", minval = 2, group = grpT,
         tooltip = "Characteristic period of the filter. 144 tracks long-term trend on 1D charts (roughly five months of bars).")
tpcMult  = input.float(1.414, "Range Multiplier", minval = 0, step = 0.1, group = grpT,
         tooltip = "Band width in multiples of filtered true range. 1.414 (√2) is the Trend Pulse default — wide enough to filter noise yet narrow enough to catch breakouts quickly.")
lagMode  = input.bool(true, "Lag Mode (zero-lag pre-transform)", group = grpT,
         tooltip = "When ON, applies Ehlers' zero-lag trick x := x + (x - x[lag]) to BOTH the price source and the true-range stream BEFORE the filter. Sharpens breakout timing. Recommended ON.")

grpO = "OBV confirmation filter"
useObv   = input.bool(true, "Require OBV > EMA(OBV, N)", group = grpO,
         tooltip = "Volume confirmation. When ON, long entries only fire if On-Balance Volume is above its own EMA — evidence that volume is pushing price up, not just price drifting through the band. This is the key v3.0 addition.")
obvLen   = input.int(60, "OBV EMA Length", minval = 2, group = grpO,
         active = useObv,
         tooltip = "EMA length applied to OBV for the confirmation filter. 60 captures medium-term accumulation/distribution; shorter values (20-30) admit more false breakouts, longer values (100+) filter out too many good signals.")

grpR = "Regime filter"
useRegime= input.bool(true, "Require close > regime EMA", group = grpR,
         tooltip = "Trend filter. When ON, long entries only fire if close is above the regime EMA. Skips breakouts that occur in clear downtrends.")
regLen   = input.int(50, "Regime EMA Length", minval = 2, group = grpR,
         active = useRegime,
         tooltip = "EMA length for the regime filter. 50 balances responsiveness and trend quality on 1D crypto; longer values (100/200) filter too much, shorter values admit too much chop.")

grpE = "Exit logic"
exitOnMid    = input.bool(true, "Exit on close < TPC midline", group = grpE,
         tooltip = "When ON, exits when price closes below the TPC filter midline (the smoothed price). Much faster than waiting for the upper band to break back down.")
exitOnRegime = input.bool(true, "Exit on close < regime EMA", group = grpE,
         tooltip = "When ON, exits when price closes below the regime EMA. Acts as a hard trend-break stop. Runs in parallel with the midline exit — whichever fires first wins.")

grpS = "Risk — ATR stop"
atrLen   = input.int(14, "ATR Length", minval = 1, group = grpS,
         tooltip = "ATR lookback used to scale the stop distance. 14 is the Wilder default.")
atrMult  = input.float(1.7, "ATR Stop Multiplier", minval = 0.1, step = 0.1, group = grpS,
         tooltip = "Stop distance = ATR × multiplier, fixed at entry. Tightened from v2.0's 2.0 to 1.7 because the OBV filter removes weaker breakouts, so tighter risk on the remaining signals improves expectancy.")

// ──────────────────────── Indicators ────────────────────────
// True range (shared with the TPC upper-band calculation)
trTrue   = ta.tr(true)

// Lag Mode pre-transform — applied BEFORE the filter
lagN     = int((tpcPeriod - 1) / (2 * tpcPoles))
srcIn    = lagMode ? tpcSrc + (tpcSrc - tpcSrc[lagN]) : tpcSrc
trIn     = lagMode ? trTrue + (trTrue - trTrue[lagN]) : trTrue

// Gaussian filter constants (uses 1.414, the truncated √2, per Pine convention)
pi       = math.asin(1) * 2
beta     = (1 - math.cos(2 * pi / tpcPeriod)) / (math.pow(1.414, 2.0 / tpcPoles) - 1)
alpha    = -beta + math.sqrt(beta * beta + 2 * beta)

aiFilter(_src, _alpha, _poles) =>
    int lenEma = math.max(1, int(2.0 / _alpha))
    float r = ta.ema(_src, lenEma)
    if _poles >= 2
        r := ta.ema(r, lenEma)
    if _poles >= 3
        r := ta.ema(r, lenEma)
    if _poles >= 4
        r := ta.ema(r, lenEma)
    r

tpcFilt   = aiFilter(srcIn, alpha, tpcPoles)
tpcFiltTR = aiFilter(trIn,  alpha, tpcPoles)
tpcUpper  = tpcFilt + tpcFiltTR * tpcMult

// OBV volume-confirmation filter
obvVal    = ta.obv
obvEMA    = ta.ema(obvVal, obvLen)
obvOk     = useObv ? obvVal > obvEMA : true

// Regime filter
regimeMA  = ta.ema(close, regLen)
regimeOk  = useRegime ? close > regimeMA : true

// ATR-based stop — prior-bar ATR to match the Python engine's shift(1) timing
atrVal    = ta.atr(atrLen)
stopOffset= atrVal[1] * atrMult

// ──────────────────────── Entry / Exit logic ────────────────────────
// Entry: close crosses above the TPC upper band AND regime OK AND OBV confirming
tpcBreakout = ta.crossover(close, tpcUpper)
longEntry   = tpcBreakout and regimeOk and obvOk and inRange

// Exit: close < TPC midline OR close < regime EMA (whichever first)
midExit     = exitOnMid    and close < tpcFilt
regimeExit  = exitOnRegime and useRegime and close < regimeMA
longExit    = midExit or regimeExit

// Snapshot ATR stop at entry so it stays fixed (matches engine's sl_offset)
var float stopPrice = na
if longEntry and strategy.position_size == 0
    strategy.entry("long", strategy.long)
    stopPrice := close - stopOffset
if strategy.position_size > 0
    strategy.exit("sl", "long", stop = stopPrice)
if strategy.position_size == 0
    stopPrice := na
if longExit and strategy.position_size > 0 and inRange
    strategy.close("long")

// ──────────────────────── Plots ────────────────────────
plot(tpcUpper,  "TPC Upper",   color.new(color.orange, 20))
plot(tpcFilt,   "TPC Midline", color.new(color.orange, 60))
plot(regimeMA,  "Regime EMA",  color.new(color.purple, 30))
plotshape(longEntry and strategy.position_size == 0,
          title = "Long Entry", style = shape.triangleup,
          location = location.belowbar, color = color.new(color.green, 0), size = size.small)
plotshape(longExit and strategy.position_size > 0,
          title = "Long Exit",  style = shape.triangledown,
          location = location.abovebar, color = color.new(color.red,   0), size = size.small)
````
