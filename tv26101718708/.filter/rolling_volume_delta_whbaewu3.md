# Rolling Volume Delta

- url: https://www.tradingview.com/script/whBAEwu3-Rolling-Volume-Delta/
- type: indicator
- pine_id: PUB;6da267eb3cfb472c84e2ea02790723ae
- version: 1.0

## Description

█ OVERVIEW

Rolling Volume Delta (RVD) estimates net buying vs. selling pressure per bar, then weights that pressure by how much price actually moved — so a strong directional bar counts for more than a quiet, indecisive one. The result is summed over a rolling window, smoothed, and normalized against total volume so it reads consistently across different instruments and volume regimes.

█ CONCEPT

Most volume delta tools estimate buy/sell pressure and stop there. RVD adds one more step: it multiplies each bar's estimated delta by the magnitude of that bar's price change. The logic is that a bar where buyers dominate AND price actually moved higher represents more conviction than a bar with the same buy/sell split during a flat, choppy stretch. That weighted delta is then summed over a rolling window and smoothed, so the final line reflects sustained pressure rather than single-bar noise.

█ HOW IT WORKS

1. Buy/sell split: each bar's volume is divided between buy and sell based on where the close landed within that bar's high-low range (close near the high = buy-weighted, close near the low = sell-weighted).
2. Price weighting: that delta is multiplied by the percentage price change over a configurable lookback, so bars with bigger moves are weighted more heavily.
3. Rolling sum: the weighted delta is summed over a configurable lookback window.
4. Smoothing: an EMA is applied to reduce noise.
5. Normalization: the smoothed result is divided by total volume over the same window and expressed as a percentage, keeping the scale comparable across tickers and sessions.

█ HOW IT DIFFERS FROM OTHER VOLUME DELTA SCRIPTS

Other delta oscillators calculate buy/sell pressure and smooth it directly. RVD's price-weighting step means the indicator isn't just "how much delta happened" but "how much delta happened relative to how much the market actually moved" — filtering out high-volume, low-conviction chop from the signal.

█ SETTINGS

- Lookback Length — bars summed together for the rolling delta. Longer = smoother, slower.
- Smoothing — EMA length applied to the rolling sum.
- Momentum Lookback — bars back used to measure price change for weighting. Higher values emphasize sustained moves over single-bar spikes.

As bars carry more information on their own (higher timeframes), less summing and smoothing is needed for a clean read. Within any timeframe, trending conditions benefit from longer/smoother settings that confirm sustained pressure and filter chop, while ranging conditions benefit from shorter/quicker settings that catch reversals near the extremes at the cost of more false flips in the middle of the range.

Suggested starting points:

Timeframe | Condition | Length | Smoothing | Momentum Lookback
5-30 min | Trend / Price Discovery | 14-20 | 3-5 | 1-2
5-30 min | Range / Accumulation | 8-10 | 1-2 | 1
1-4 hour | Trend / Price Discovery | 10-14 | 2-3 | 2-4
1-4 hour | Range / Accumulation | 6-8 | 1-2 | 1-2
Daily+ | Trend / Price Discovery | 8-10 | 2 | 3-5
Daily+ | Range / Accumulation | 5-6 | 1 | 2

These are included in each input's tooltip in the settings popup as well.

█ NOTES

This is a volume-estimation tool based on standard OHLCV data (bar range and close position), not true tick-level buy/sell data — most retail data feeds don't provide that, so this is the same practical tradeoff most public volume delta scripts make. It's intended as a context tool for reading order flow alongside price action, not a standalone signal generator.

This publication is for educational purposes only and does not constitute financial advice. Past performance and visual patterns do not guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © karlssont678

//@version=6
//@version=5
indicator("Rolling Volume Delta", shorttitle="RVD", overlay=false)

// ================== SETTINGS ==================
// Hover the (i) icon next to each input in the settings popup for an explanation.

length = input.int(14, "Lookback Length",
     minval=1,
     tooltip="How many bars of buy/sell pressure get added together. Bigger = smoother, slower to react. Smaller = choppier, faster to react.\n\nTrend / Price Discovery:\n5-30 min   ->  14-20\n1-4 hour   ->  10-14\nDaily+     ->  8-10\n\nRange / Accumulation:\n5-30 min   ->  8-10\n1-4 hour   ->  6-8\nDaily+     ->  5-6")

smoothLen = input.int(3, "Smoothing",
     minval=1,
     tooltip="Softens the final line so it doesn't jump around bar to bar. Higher = smoother.\n\nTrend / Price Discovery:\n5-30 min   ->  3-5\n1-4 hour   ->  2-3\nDaily+     ->  2\n\nRange / Accumulation:\n5-30 min   ->  1-2\n1-4 hour   ->  1-2\nDaily+     ->  1")

priceLookback = input.int(1, "Momentum Lookback",
     minval=1,
     tooltip="How far back price is compared to judge how strong the current move is. Bars with bigger price moves get weighted more heavily. 1 = very reactive to the last bar; higher = reacts to sustained moves instead of single spikes.\n\nTrend / Price Discovery:\n5-30 min   ->  1-2\n1-4 hour   ->  2-4\nDaily+     ->  3-5\n\nRange / Accumulation:\n5-30 min   ->  1\n1-4 hour   ->  1-2\nDaily+     ->  2")

// ================== CALCULATIONS ==================

// Estimate buy vs. sell volume from where price closed within the bar's range.
// Close near the high = buyers in control. Close near the low = sellers in control.
barRange = high - low
buyVolume  = barRange != 0 ? volume * (close - low) / barRange : volume * 0.5
sellVolume = barRange != 0 ? volume * (high - close) / barRange : volume * 0.5
delta = buyVolume - sellVolume

// Weight that delta by how much price actually moved, so strong directional
// bars count more than quiet, indecisive ones.
priceMove = close - close[priceLookback]
priceMovePct = close[priceLookback] != 0 ? (priceMove / close[priceLookback]) * 100 : 0.0
weightedDelta = delta * (1 + math.abs(priceMovePct))

// Add up pressure over the lookback window, then smooth the result.
rollingDelta = math.sum(weightedDelta, length)
smoothedDelta = ta.ema(rollingDelta, smoothLen)

// Normalize against total volume in the same window so the scale stays
// consistent across different tickers, sessions, and volume levels.
rollingVolume = math.sum(volume, length)
output = rollingVolume != 0 ? (smoothedDelta / rollingVolume) * 100 : 0.0

// ================== PLOT ==================

plot(output, title="Volume Delta",
     style=plot.style_columns,
     color = output >= 0 ? color.new(color.green, 0) : color.new(color.red, 0))

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// ================== ALERTS ==================

alertcondition(ta.crossover(output, 0), title="Delta crosses above 0", message="Volume Delta turned bullish")
alertcondition(ta.crossunder(output, 0), title="Delta crosses below 0", message="Volume Delta turned bearish")
````
