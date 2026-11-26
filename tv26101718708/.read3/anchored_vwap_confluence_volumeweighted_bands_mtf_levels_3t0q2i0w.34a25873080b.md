Calculation: selected volume = instrument volume, or selected proxy instrument volume when instrument volume has not appeared and proxy volume is available
Calculation: anchored VWAP = VWAP(source, selected volume) from the rolling lookback on chart bars in rolling mode, or from the selected confirmed swing pivot through the current chart bar in swing mode; pivot high and low use the pivot lookback; dual mode selects the more recent pivot, choosing the low on a tie; use rolling VWAP until a pivot is available
Calculation: volume-weighted sigma = sqrt(max(VWAP(source², selected volume, same anchor as anchored VWAP) - anchored VWAP², 0))
Calculation: decayed VWAP = recursively update numerator as λ × prior numerator + source × selected volume and denominator as λ × prior denominator + selected volume, then divide numerator by denominator; λ = 0.5^(1 / half-life); reset on each newly confirmed pivot selected by anchor mode, or only at initialization in rolling mode
Calculation: higher-timeframe VWAP(T) = rolling VWAP(source, selected volume, rolling lookback) calculated on T bars and read by chart bars with lookahead off, using the last completed T bar historically and the still-forming T bar in real time; T1, T2, and T3 are higher than the chart timeframe in increasing duration
Long: decayed VWAP >= anchored VWAP
Short: decayed VWAP <= anchored VWAP
Long: anchored VWAP is available AND decayed VWAP crosses above anchored VWAP AND (regime filter is disabled OR (efficiency ratio(close, lookback) > ER threshold AND ADX(high, low, close, length, smoothing) > ADX threshold))
Short: anchored VWAP is available AND decayed VWAP crosses below anchored VWAP AND (regime filter is disabled OR (efficiency ratio(close, lookback) > ER threshold AND ADX(high, low, close, length, smoothing) > ADX threshold))
Long: anchored VWAP is available AND rolling VWAP(source, selected volume, rolling lookback) crosses above anchored VWAP
Short: anchored VWAP is available AND rolling VWAP(source, selected volume, rolling lookback) crosses below anchored VWAP
Long: volume-weighted sigma > 0 AND (source - anchored VWAP) / volume-weighted sigma <= -stretch threshold
Short: volume-weighted sigma > 0 AND (source - anchored VWAP) / volume-weighted sigma >= stretch threshold
Long: higher-timeframe VWAP(T1) is available AND close >= higher-timeframe VWAP(T1)
Short: higher-timeframe VWAP(T1) is available AND close < higher-timeframe VWAP(T1)
Long: higher-timeframe VWAP(T2) is available AND close >= higher-timeframe VWAP(T2)
Short: higher-timeframe VWAP(T2) is available AND close < higher-timeframe VWAP(T2)
Long: higher-timeframe VWAP(T3) is available AND close >= higher-timeframe VWAP(T3)
Short: higher-timeframe VWAP(T3) is available AND close < higher-timeframe VWAP(T3)
Long: sum of sign(close - higher-timeframe VWAP(T)) for each available T in {T1, T2, T3}, treating unavailable values as zero, > 0
Short: sum of sign(close - higher-timeframe VWAP(T)) for each available T in {T1, T2, T3}, treating unavailable values as zero, < 0