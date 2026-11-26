Calculation: Small candle = ABS(close - open) <= (high - low) * small-candle body percentage / 100 OR high = low
Calculation: Long stop = MIN(setup-candle low, EMA(close, longer EMA lookback) on setup candle)
Calculation: Short stop = MAX(setup-candle high, EMA(close, longer EMA lookback) on setup candle)
Calculation: Long target = entry price + (entry price - Long stop) * risk/reward parameter
Calculation: Short target = entry price - (Short stop - entry price) * risk/reward parameter
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND EMA(close, shorter EMA lookback, T1, still-forming T1 bar sampled on chart bars) > EMA(close, longer EMA lookback, T1, still-forming T1 bar sampled on chart bars) AND low <= EMA(close, shorter EMA lookback) AND close > EMA(close, longer EMA lookback) AND Small candle AND MACD(close, fast lookback, slow lookback, signal smoothing).line > MACD(close, fast lookback, slow lookback, signal smoothing).signal
Short: EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND EMA(close, shorter EMA lookback, T1, still-forming T1 bar sampled on chart bars) < EMA(close, longer EMA lookback, T1, still-forming T1 bar sampled on chart bars) AND high >= EMA(close, shorter EMA lookback) AND close < EMA(close, longer EMA lookback) AND Small candle AND MACD(close, fast lookback, slow lookback, signal smoothing).line < MACD(close, fast lookback, slow lookback, signal smoothing).signal
Long: After a long setup, high >= setup-candle high before a chart bar closes below EMA(close, longer EMA lookback)
Short: After a short setup, low <= setup-candle low before a chart bar closes above EMA(close, longer EMA lookback)
Exit: long, low <= Long stop OR high >= Long target
Exit: short, high >= Short stop OR low <= Short target