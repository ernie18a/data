Calculation: Center = EMA, volume-weighted moving average, or Hull moving average of close, using the same selected model throughout.
Calculation: Width = (1 - blend weight) × ATR + blend weight × standard deviation of close, using the same volatility lookback for both; if the blend is unavailable or nonpositive, use ATR, falling back to true range when ATR is unavailable.
Calculation: Inner and outer bands = center ± width × the respective inner or outer multiplier.
Calculation: Trend slope = (center minus its value a trend-lookback number of bars earlier) / trend lookback / ATR, calculated on the chart timeframe or on the last completed higher-timeframe bar; use zero if ATR is nonpositive. The higher-timeframe center and ATR use the same model and respective lookbacks as the chart-timeframe calculations. Strong uptrend means the filter is enabled AND trend slope > a nonnegative threshold; strong downtrend means the filter is enabled AND trend slope < the negative of that threshold.
Calculation: Latest extreme = the direction of the most recent close crossover above the upper outer band or close crossunder below the lower outer band; replace it on a new outer-band cross, and clear it after the confirmation window or after either reversion decision.
Long: Close >= lower inner band AND close <= lower outer band AND strong downtrend is false.
Long: Close < lower inner band AND close > lower outer band AND strong downtrend is false.
Long: Latest extreme is down AND close crosses above the lower inner band AND strong downtrend is false.
Long: Close > upper outer band AND strong uptrend AND the preceding bar did not satisfy both conditions.
Short: Close <= upper inner band AND close >= upper outer band AND strong uptrend is false.
Short: Close > upper inner band AND close < upper outer band AND strong uptrend is false.
Short: Latest extreme is up AND close crosses below the upper inner band AND strong uptrend is false.
Short: Close < lower outer band AND strong downtrend AND the preceding bar did not satisfy both conditions.