Calculation: Adaptive lookback = ceiling(base lookback / ADX(ADX lookback, T1, last completed bar))
Calculation: Range = Highest(high, adaptive lookback, T1 bars including the still-forming bar) - Lowest(low, adaptive lookback, T1 bars including the still-forming bar)
Calculation: Upper threshold = Highest(high, adaptive lookback, T1 bars including the still-forming bar) - Range * compression percentage / 100
Calculation: Lower threshold = Lowest(low, adaptive lookback, T1 bars including the still-forming bar) + Range * compression percentage / 100
Calculation: Direction state = bullish when T1 close > upper threshold, bearish when T1 close < lower threshold, otherwise the prior T1 direction state
Long: current T1 close > upper threshold AND last completed T1 direction state is bearish (read on chart bars using the still-forming T1 bar)
Short: current T1 close < lower threshold AND last completed T1 direction state is bullish (read on chart bars using the still-forming T1 bar)