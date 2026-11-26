Calculation: Score = EMA weight * (1 if close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback), else 0) + RSI weight * (1 if RSI(close, RSI lookback) > lower RSI bound AND RSI(close, RSI lookback) < upper RSI bound, else 0) + MACD weight * (1 if MACD line(close, shorter MACD lookback, longer MACD lookback, signal lookback) > MACD signal line(close, shorter MACD lookback, longer MACD lookback, signal lookback), else 0) + Supertrend weight * (1 if Supertrend direction(Supertrend multiplier, Supertrend lookback) < 0, else 0) + momentum weight * (1 if MOM(close, momentum lookback) / close[momentum lookback] * 100 > 0, else 0) + Bollinger weight * (1 if close > Bollinger upper(close, Bollinger lookback, deviation multiplier), else 0)
Long: close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Short: close <= EMA(close, shorter EMA lookback) OR EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback)
Long: MACD line(close, shorter MACD lookback, longer MACD lookback, signal lookback) > MACD signal line(close, shorter MACD lookback, longer MACD lookback, signal lookback)
Short: MACD line(close, shorter MACD lookback, longer MACD lookback, signal lookback) <= MACD signal line(close, shorter MACD lookback, longer MACD lookback, signal lookback)
Long: Supertrend direction(Supertrend multiplier, Supertrend lookback) < 0
Short: Supertrend direction(Supertrend multiplier, Supertrend lookback) >= 0
Long: close > Bollinger upper(close, Bollinger lookback, deviation multiplier)
Short: close < Bollinger lower(close, Bollinger lookback, deviation multiplier)
Long: Score > score threshold