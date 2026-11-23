Calculation: EMA score = 2 if EMA(close, short EMA length) > EMA(close, mid EMA length) AND EMA(close, mid EMA length) > EMA(close, long EMA length) AND close > EMA(close, short EMA length), else 1 if EMA(close, short EMA length) > EMA(close, mid EMA length) AND EMA(close, mid EMA length) > EMA(close, long EMA length), else -2 if EMA(close, short EMA length) < EMA(close, mid EMA length) AND EMA(close, mid EMA length) < EMA(close, long EMA length) AND close < EMA(close, short EMA length), else -1 if EMA(close, short EMA length) < EMA(close, mid EMA length) AND EMA(close, mid EMA length) < EMA(close, long EMA length), else 1 if close > EMA(close, long EMA length), else -1 if close < EMA(close, long EMA length), else 0
Calculation: OBV moving average = SMA(OBV(close, volume), OBV MA length)
Calculation: OBV score = 1 if OBV(close, volume) > OBV moving average AND OBV moving average > OBV moving average[slope lookback], else -1 if OBV(close, volume) <= OBV moving average AND OBV moving average < OBV moving average[slope lookback], else 0
Calculation: Trend score = EMA score + (1 if Supertrend(high, low, close, Supertrend factor, Supertrend ATR length) < close, else -1) + OBV score
Long: Supertrend(high, low, close, Supertrend factor, Supertrend ATR length) < close AND Supertrend(high, low, close, Supertrend factor, Supertrend ATR length)[1] >= close[1]
Short: Supertrend(high, low, close, Supertrend factor, Supertrend ATR length) >= close AND Supertrend(high, low, close, Supertrend factor, Supertrend ATR length)[1] < close[1]
Long: Supertrend(high, low, close, Supertrend factor, Supertrend ATR length) < close
Short: Supertrend(high, low, close, Supertrend factor, Supertrend ATR length) >= close
Long: EMA(close, short EMA length) > EMA(close, mid EMA length) AND EMA(close, mid EMA length) > EMA(close, long EMA length)
Short: EMA(close, short EMA length) < EMA(close, mid EMA length) AND EMA(close, mid EMA length) < EMA(close, long EMA length)
Long: EMA(close, mid EMA length) crosses above EMA(close, long EMA length)
Short: EMA(close, mid EMA length) crosses below EMA(close, long EMA length)
Long: Trend score >= 3 AND Trend score[1] < 3
Short: Trend score <= -3 AND Trend score[1] > -3