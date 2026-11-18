Calculation: relative-performance ratio = close / benchmark close on the current chart bar
Calculation: relative-performance score = scale parameter × (relative-performance ratio − Lowest(relative-performance ratio, chart lookback)) / max(denominator-floor parameter, Highest(relative-performance ratio, chart lookback) − Lowest(relative-performance ratio, chart lookback))
Calculation: trend-template score = count of true conditions: relative-performance score > relative-performance threshold; close > SMA(close, short lookback); close > SMA(close, intermediate lookback); close > SMA(close, long lookback); SMA(close, short lookback) > SMA(close, intermediate lookback); SMA(close, short lookback) > SMA(close, long lookback); SMA(close, intermediate lookback) > SMA(close, long lookback); close >= Lowest(low, T1 lookback, T1 bars, forming bar sampled on chart bars with lookahead off) × (1 + low-distance parameter); close >= Highest(high, T1 lookback, T1 bars, forming bar sampled on chart bars with lookahead off) × (1 − high-distance parameter); SMA(close, long lookback) > SMA(close, long lookback)[lag]
Long: trend-template score == number of trend-template criteria
Long: trend-template score >= highest partial-score alert threshold
Long: trend-template score >= next-lower partial-score alert threshold
Long: trend-template score >= middle partial-score alert threshold
Long: trend-template score >= next-higher-than-lowest partial-score alert threshold
Long: trend-template score >= lowest partial-score alert threshold