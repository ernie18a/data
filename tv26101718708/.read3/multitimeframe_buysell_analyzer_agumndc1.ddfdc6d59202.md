Calculation: Long score = count of true conditions among: (close > EMA(close, trend lookback) AND EMA(close, fast lookback) > EMA(close, slow lookback)); (EMA(close, fast lookback) crosses above EMA(close, slow lookback) OR MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line crosses above its signal line); (RSI(close, RSI lookback) > long RSI threshold AND RSI(close, RSI lookback) < upper RSI bound); (volume > SMA(volume, volume lookback) * volume multiplier)
Calculation: Short score = count of true conditions among: (close < EMA(close, trend lookback) AND EMA(close, fast lookback) < EMA(close, slow lookback)); (EMA(close, fast lookback) crosses below EMA(close, slow lookback) OR MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line crosses below its signal line); (RSI(close, RSI lookback) < short RSI threshold AND RSI(close, RSI lookback) > lower RSI bound); (volume > SMA(volume, volume lookback) * volume multiplier)
Calculation: T1 trend status = 1 if close from T1's still-forming bar > EMA(close, trend lookback, T1, still-forming bar) AND EMA(close, fast lookback, T1, still-forming bar) > EMA(close, slow lookback, T1, still-forming bar); -1 if both comparisons are <; otherwise 0, evaluated on chart bars using the same EMA lookbacks as on chart
Calculation: T2 trend status = 1 if close from T2's still-forming bar > EMA(close, trend lookback, T2, still-forming bar) AND EMA(close, fast lookback, T2, still-forming bar) > EMA(close, slow lookback, T2, still-forming bar); -1 if both comparisons are <; otherwise 0, evaluated on chart bars using the same EMA lookbacks as on chart
Calculation: T3 trend status = 1 if close from T3's still-forming bar > EMA(close, trend lookback, T3, still-forming bar) AND EMA(close, fast lookback, T3, still-forming bar) > EMA(close, slow lookback, T3, still-forming bar); -1 if both comparisons are <; otherwise 0, evaluated on chart bars using the same EMA lookbacks as on chart
Calculation: T4 trend status = 1 if close from T4's still-forming bar > EMA(close, trend lookback, T4, still-forming bar) AND EMA(close, fast lookback, T4, still-forming bar) > EMA(close, slow lookback, T4, still-forming bar); -1 if both comparisons are <; otherwise 0, evaluated on chart bars using the same EMA lookbacks as on chart
Calculation: Bullish multi-timeframe agreement = T1 trend status >= 0 AND T2 trend status = 1 AND T3 trend status = 1 AND T4 trend status = 1
Calculation: Bearish multi-timeframe agreement = T1 trend status <= 0 AND T2 trend status = -1 AND T3 trend status = -1 AND T4 trend status = -1
Calculation: Long base signal = (EMA(close, fast lookback) crosses above EMA(close, slow lookback) OR MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line crosses above its signal line OR (close > EMA(close, trend lookback) AND EMA(close, fast lookback) > EMA(close, slow lookback) AND close <= EMA(close, fast lookback) AND close > EMA(close, slow lookback))) AND Long score >= minimum score threshold AND (multi-timeframe agreement is disabled OR bullish multi-timeframe agreement)
Calculation: Short base signal = (EMA(close, fast lookback) crosses below EMA(close, slow lookback) OR MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) line crosses below its signal line OR (close < EMA(close, trend lookback) AND EMA(close, fast lookback) < EMA(close, slow lookback) AND close >= EMA(close, fast lookback) AND close < EMA(close, slow lookback))) AND Short score >= minimum score threshold AND (multi-timeframe agreement is disabled OR bearish multi-timeframe agreement)
Calculation: Stored signal side = long if Long base signal is true and the prior stored signal side is not long; otherwise short if Short base signal is true and the prior stored signal side is not short; otherwise the prior stored signal side; initially neutral
Long: RSI(close, RSI lookback) < lower RSI bound
Short: RSI(close, RSI lookback) > upper RSI bound
Long: T1 trend status = 1
Short: T1 trend status = -1
Long: T2 trend status = 1
Short: T2 trend status = -1
Long: T3 trend status = 1
Short: T3 trend status = -1
Long: T4 trend status = 1
Short: T4 trend status = -1
Long: bullish multi-timeframe agreement
Short: bearish multi-timeframe agreement
Long: Long base signal AND (prior stored signal side is not long OR Long score >= strong-signal score threshold)
Short: Short base signal AND (prior stored signal side is not short OR Short score >= strong-signal score threshold)