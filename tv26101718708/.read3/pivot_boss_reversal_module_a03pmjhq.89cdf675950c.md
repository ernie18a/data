Calculation: candle range = high - low
Calculation: candle body = abs(close - open)
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: candle midpoint = (high + low) / 2
Long: lower wick >= candle body * wick multiplier AND upper wick <= candle body AND close >= low + candle range * (1 - body-position parameter) OR low < low[1] AND close > high[1] OR high > high[1] AND low < low[1] AND close > open AND close > candle midpoint OR candle range > 0 AND candle body / candle range <= doji body-to-range threshold AND close > close[1]
Short: upper wick >= candle body * wick multiplier AND lower wick <= candle body AND close <= low + candle range * body-position parameter OR high > high[1] AND close < low[1] OR high > high[1] AND low < low[1] AND close < open AND close < candle midpoint OR candle range > 0 AND candle body / candle range <= doji body-to-range threshold AND close < close[1]