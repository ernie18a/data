Calculation: Source = a selectable price series computed from the OHLC fields.
Calculation: Relative momentum index = let change be source minus source a momentum lookback ago, substituting current source when the past value is unavailable; smooth max(change, 0) and max(-change, 0) separately with Wilder's moving average; return 100 if smoothed losses are zero, 0 if smoothed gains are zero, otherwise 100 - 100 / (1 + smoothed gains / smoothed losses).
Calculation: WaveTrend flow = clamp EMA((source - fast EMA(source)) / (0.015 × fast EMA(abs(source - fast EMA(source)))), using 0 when the denominator is zero, to a slower EMA length; divide by 1.5 and clamp to [-100, 100].
Calculation: ATR ratio = ATR divided by its longer-baseline SMA, or 1 when that SMA is zero.
Calculation: Compression = clamp (1 - ATR ratio) × 100 to [0, 100].
Calculation: Expansion = clamp (ATR ratio - 1) × 100 to [-100, 100].
Calculation: Directional bias = 1 when close >= EMA(close), otherwise -1.
Calculation: Flow = EMA of the weighted average of (relative momentum index - 50) × 2, (money flow index of HLC3 - 50) × 2, WaveTrend flow, and expansion × directional bias; divide by the greater of the sum of their nonnegative weights and 0.0001, then clamp the result to [-100, 100] before smoothing.
Calculation: Signal = EMA(flow).
Long: Flow crosses above signal AND flow > negative strong threshold.
Short: Flow crosses below signal AND flow < strong threshold.
Long: Flow crosses above strong threshold OR flow crosses above extreme threshold.
Short: Flow crosses below negative strong threshold OR flow crosses below negative extreme threshold.
Long: Previous compression >= compression threshold AND current compression < compression threshold AND flow > 0 AND flow > signal.
Short: Previous compression >= compression threshold AND current compression < compression threshold AND flow < 0 AND flow < signal.
Long: Flow >= 0 OR flow >= signal OR WaveTrend flow >= 0.
Short: Flow < 0 OR flow < signal OR WaveTrend flow < 0.