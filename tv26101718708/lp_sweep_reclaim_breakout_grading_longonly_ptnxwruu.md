# LP Sweep / Reclaim & Breakout Grading: Long-only

- url: https://www.tradingview.com/script/ptNxWRuu-LP-Sweep-Reclaim-Breakout-Grading-Long-only/
- type: strategy
- pine_id: PUB;6d6fee04d56e4460bf485feab7080aa8
- version: 2.0

## Description

Signals
1) LP Sweep & Reclaim (mean-reversion entry)

Compute LP bounds from prior-bar window extremes:

lpLL_prev = lowest low of the last N bars (offset 1).

lpHH_prev = highest high of the last N bars (offset 1).

Sweep long trigger: current low dips below lpLL_prev and closes back above it.

Real-time quality grading (A/B/C) for sweep:

Trend filter & slope via EMA(88).

BOS bonus: close > last confirmed swing high.

Body size vs ATR, location above a long EMA, headroom to swing high (penalty if too close), and multi-sweep count bonus.

Sum → score → grade A/B/C; A or B required for sweep entry.

2) Trend Breakout (momentum entry)

Core trigger: close > previous Donchian high (length boLen) + ATR buffer.

Optional filter: close must be above the default EMA.

Breakout grading (A/B/C) in real time combining:

Trend up (price > EMA and EMA rising),

Body/ATR, Gap above breakout level (in ATR),

Volume vs MA,

Upper-wick penalty,

Position-in-Score: headroom to last swing high (penalty if too near) + EMA slope bonus.

Sum → score → A or B required if grading enabled.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Shihyuuu

//@version=6
strategy("My strategy", overlay=true, fill_orders_on_standard_ohlc = true)

longCondition = ta.crossover(ta.sma(close, 14), ta.sma(close, 28))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = ta.crossunder(ta.sma(close, 14), ta.sma(close, 28))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
