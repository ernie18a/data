Calculation: candle body strength = (close - open) / (high - low) when high > low, otherwise 0
Calculation: body-to-range ratio = abs(close - open) / (high - low) when high > low, otherwise 0
Long: close > SMA(close, short lookback) AND SMA(close, short lookback) != SMA(close, long lookback)
Short: close < SMA(close, short lookback) AND SMA(close, short lookback) != SMA(close, long lookback)
Long: CMF(lookback) > flow threshold
Short: CMF(lookback) < -flow threshold
Long: body-to-range ratio >= doji threshold AND candle body strength > 0
Short: body-to-range ratio >= doji threshold AND candle body strength < 0