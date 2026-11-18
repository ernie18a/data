Calculation: candle range = high - low
Long: close[1] < high[1] AND close >= high[1] AND volume > volume multiplier × volume[1] AND close > open AND candle range > movement threshold AND close > EMA(close, lookback)
Short: close[1] > low[1] AND close <= low[1] AND volume > volume multiplier × volume[1] AND close < open AND candle range > movement threshold AND close < EMA(close, lookback)