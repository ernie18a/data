Calculation: EWMA volatility(x, volatility span) = sqrt(EMA((((x - x[1]) / x[1] - EMA((x - x[1]) / x[1], volatility span))^2), volatility span))
Calculation: Excess normalized momentum = (close / close[momentum lookback] - 1) / max(EWMA volatility(close, volatility span), volatility floor) - (benchmark close / benchmark close[momentum lookback] - 1) / max(EWMA volatility(benchmark close, volatility span), volatility floor), computed on T1 bars and mapped to chart bars with lookahead off (last completed T1 bar historically; current forming T1 bar in real time)
Calculation: Relative-strength score = Excess normalized momentum / StDev(Excess normalized momentum, normalization lookback) when that standard deviation is greater than zero; otherwise undefined
Calculation: Relative-strength rank = 1-based descending rank of defined scores among configured symbols, with ties retaining configured slot order
Calculation: Benchmark normalized momentum = (benchmark close / benchmark close[momentum lookback] - 1) / max(EWMA volatility(benchmark close, volatility span), volatility floor), computed on T1 bars and mapped to chart bars with lookahead off (last completed T1 bar historically; current forming T1 bar in real time)
Calculation: Opening-range bounds = (highest(high), lowest(low)) over the configured opening-range session and timezone, computed on T1 bars and mapped to chart bars with lookahead off (last completed T1 bar historically; current forming T1 bar in real time)
Calculation: Opening-range direction = reset to 0 at each calendar-date boundary; after the opening-range session, set to +1 on the first close above the opening-range high or -1 on the first close below the opening-range low, and retain that direction until the next calendar-date boundary
Long: Benchmark normalized momentum > 0
Short: Benchmark normalized momentum < 0
Long: Relative-strength rank <= N
Short: Relative-strength rank > N AND Relative-strength rank >= active-symbol count - N + 1
Long: Opening-range direction = +1
Short: Opening-range direction = -1