Calculation: Momentum = 100 × EMA(short smoothing, EMA(long smoothing, price change)) / EMA(short smoothing, EMA(long smoothing, absolute price change)); use 0 when the denominator is 0. Price change is the selected price source minus its previous value.
Calculation: Bounded momentum = 100 × tanh(momentum / scale), with the tanh input clamped to a fixed symmetric limit.
Calculation: Confirmed price pivot = a high or low surrounded by the configured number of bars on each side whose highs are no higher or lows are no lower, respectively; recognize it only after the right-side bars have completed. Compare each pivot with the immediately preceding confirmed pivot of the same kind.
Calculation: Higher-timeframe divergence state = sample the last completed higher-timeframe high, low, and bounded momentum onto chart bars; detect pivots on these sampled chart-bar series using equal left and right pivot lengths. At a confirmed high pivot, set the state to bearish if its sampled high is greater and sampled momentum is lower than at the preceding confirmed high pivot. At a confirmed low pivot, set the state to bullish if its sampled low is lower and sampled momentum is higher than at the preceding confirmed low pivot. Otherwise retain the prior state; start with neither state. If both occur together, the bearish state takes precedence.
Calculation: Efficiency ratio = absolute change in close over the regime lookback divided by the sum of absolute one-bar close changes over that lookback; use 0 when the denominator is 0.
Calculation: Regular bullish divergence = a confirmed low pivot has a lower low and higher bounded momentum than the preceding confirmed low pivot, and their bar distance is at most the maximum pivot separation.
Calculation: Hidden bullish divergence = a confirmed low pivot has a higher low and lower bounded momentum than the preceding confirmed low pivot, and their bar distance is at most the maximum pivot separation.
Calculation: Regular bearish divergence = a confirmed high pivot has a higher high and lower bounded momentum than the preceding confirmed high pivot, and their bar distance is at most the maximum pivot separation.
Calculation: Hidden bearish divergence = a confirmed high pivot has a lower high and higher bounded momentum than the preceding confirmed high pivot, and their bar distance is at most the maximum pivot separation.
Calculation: Regime permission = the regime gate is disabled OR the gate is set to trending only AND efficiency ratio is above its threshold OR the gate is set to ranging only AND efficiency ratio is at or below its threshold OR the gate is set to match divergence type AND ((the divergence is regular AND efficiency ratio is at or below its threshold) OR (the divergence is hidden AND efficiency ratio is above its threshold)).
Calculation: Confirmed bullish divergence = (regular bullish divergence OR hidden divergences enabled AND hidden bullish divergence) AND regime permission AND (higher-timeframe confirmation disabled OR higher-timeframe divergence state is bullish).
Calculation: Confirmed bearish divergence = (regular bearish divergence OR hidden divergences enabled AND hidden bearish divergence) AND regime permission AND (higher-timeframe confirmation disabled OR higher-timeframe divergence state is bearish).
Long: Confirmed bullish divergence.
Short: Confirmed bearish divergence.
Long: Higher-timeframe confirmation enabled AND no confirmed bullish or bearish divergence AND (regular bullish divergence OR hidden divergences enabled AND hidden bullish divergence).
Short: Higher-timeframe confirmation enabled AND no confirmed bullish or bearish divergence AND no regular bullish divergence AND (hidden divergences disabled OR no hidden bullish divergence) AND (regular bearish divergence OR hidden divergences enabled AND hidden bearish divergence).
Long: Higher-timeframe confirmation enabled AND higher-timeframe divergence state is bullish.
Short: Higher-timeframe confirmation enabled AND higher-timeframe divergence state is bearish.
Long: Bounded momentum >= 0.
Short: Bounded momentum < 0.
Long: Momentum >= EMA(momentum, signal smoothing length).
Short: Momentum < EMA(momentum, signal smoothing length).
Long: Momentum crosses above EMA(momentum, signal smoothing length).
Short: Momentum crosses below EMA(momentum, signal smoothing length).