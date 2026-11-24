Calculation: Master RSI = weighted mean of RSI(source, RSI lookback, T1) through RSI(source, RSI lookback, T10), using separate weights for each timeframe; each RSI is calculated on its Tn bars and sampled by chart bars with lookahead off (the forming Tn bar in realtime); if the total weight is zero, use the RSI equilibrium level; subsequent calculations run on chart bars
Calculation: Bullish timeframe count = number of RSI(source, RSI lookback, T1) through RSI(source, RSI lookback, T10) values ≥ RSI equilibrium level
Calculation: Bearish timeframe count = number of RSI(source, RSI lookback, T1) through RSI(source, RSI lookback, T10) values < RSI equilibrium level
Calculation: Consensus score = consensus scale × ABS(Bullish timeframe count − Bearish timeframe count) / 10
Calculation: Probability score = Consensus score × consensus probability weight + MIN(ABS(EMA(Master RSI, fast trend lookback) − EMA(Master RSI, slow trend lookback)) × trend strength scale, trend strength cap) × trend probability weight + Fib probability × fib probability weight + ABS(Master RSI − RSI equilibrium level) × RSI score multiplier × RSI probability weight, where Fib probability is the first applicable tier score in descending order when Master RSI ≥ Lowest(Master RSI, fib lookback) + (Highest(Master RSI, fib lookback) − Lowest(Master RSI, fib lookback)) × its corresponding fib ratio, or zero if no tier applies
Long: Master RSI ≥ RSI equilibrium level
Short: Master RSI < RSI equilibrium level
Long: Bullish timeframe count > Bearish timeframe count
Short: Bearish timeframe count > Bullish timeframe count
Long: EMA(Master RSI, fast trend lookback) > EMA(Master RSI, slow trend lookback)
Short: EMA(Master RSI, fast trend lookback) < EMA(Master RSI, slow trend lookback)
Long: Consensus score ≥ trend consensus threshold AND EMA(Master RSI, fast trend lookback) > EMA(Master RSI, slow trend lookback) AND Probability score ≥ trend probability threshold AND Master RSI ≥ bull trend RSI threshold
Short: Consensus score ≥ trend consensus threshold AND EMA(Master RSI, fast trend lookback) < EMA(Master RSI, slow trend lookback) AND Probability score ≥ trend probability threshold AND Master RSI ≤ bear trend RSI threshold
Long: Consensus score < low consensus threshold AND Master RSI < RSI equilibrium level AND Probability score < low probability threshold
Short: Consensus score < low consensus threshold AND Master RSI > RSI equilibrium level AND Probability score < low probability threshold