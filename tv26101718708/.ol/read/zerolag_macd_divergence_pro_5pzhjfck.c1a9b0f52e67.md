Calculation: Zero-lag EMA = 2 × EMA(value, length) − EMA(EMA(value, length), length)
Calculation: Zero-lag MACD = zero-lag EMA(close, shorter fast length) − zero-lag EMA(close, longer slow length)
Calculation: Signal line = zero-lag EMA(Zero-lag MACD, signal length)
Calculation: Confirmed MACD pivot low/high = pivot low/high of Zero-lag MACD, confirmed after an equal lookback on both sides; compare price low/high at the same pivot bar
Long: Confirmed MACD pivot low has a lower price low and higher Zero-lag MACD value than the preceding confirmed pivot low, with the pivot gap within the configured maximum OR Zero-lag MACD crosses above the Signal line on a confirmed bar
Short: Confirmed MACD pivot high has a higher price high and lower Zero-lag MACD value than the preceding confirmed pivot high, with the pivot gap within the configured maximum OR Zero-lag MACD crosses below the Signal line on a confirmed bar