Calculation: Impulse = high - low > range multiplier * ATR(ATR lookback) AND high - low > 0 AND abs(close - open) / (high - low) >= minimum body ratio
Calculation: Volume confirmation = volume multiplier <= 0 OR (volume >= volume multiplier * SMA(volume, volume lookback) AND SMA(volume, volume lookback) > 0)
Long: on a completed chart bar, Impulse AND close > open AND Volume confirmation
Short: on a completed chart bar, Impulse AND close < open AND Volume confirmation