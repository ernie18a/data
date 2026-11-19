Calculation: BodyRatio = abs(close - open) / abs(high - low)
Calculation: CandleWickSize = if open > close then abs(high - close) else abs(low - close)
Long: close > open AND ((BodyRatio > body threshold AND volume > SMA(volume, volume lookback)) OR volume < SMA(volume, volume lookback)) OR close > open AND open[1] > close[1] AND CandleWickSize > CandleWickSize[1]
Short: NOT (close > open AND ((BodyRatio > body threshold AND volume > SMA(volume, volume lookback)) OR volume < SMA(volume, volume lookback)))