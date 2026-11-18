Calculation: BullScore = volume * (high > low ? (close >= open ? (high - low) / (2 * (high - low) - abs(close - open)) : ((high - low) - abs(close - open)) / (2 * (high - low) - abs(close - open))) : 0.5)
Calculation: NetVol = WMA(WMA(BullScore, longer lookback), shorter lookback) - WMA(WMA(volume - BullScore, longer lookback), shorter lookback)
Long: NetVol >= 0
Short: NetVol < 0