Calculation: Faith difference = SMA((high > high[1] AND volume > volume[1]) ? volume / Highest(volume, volume-normalization lookback) * volume scale : 0, averaging lookback) - SMA((low < low[1] AND volume > volume[1]) ? volume / Highest(volume, volume-normalization lookback) * volume scale : 0, averaging lookback)
Calculation: Hull agreement = (HMA(close, fast lookback) - HMA(close, fast lookback)[1] > ATR(ATR lookback) * trend threshold ? 1 : HMA(close, fast lookback) - HMA(close, fast lookback)[1] < -ATR(ATR lookback) * trend threshold ? -1 : 0) + (HMA(close, slow lookback) - HMA(close, slow lookback)[1] > ATR(ATR lookback) * trend threshold ? 1 : HMA(close, slow lookback) - HMA(close, slow lookback)[1] < -ATR(ATR lookback) * trend threshold ? -1 : 0); fast lookback is shorter than slow lookback
Long: Faith difference > 0
Short: Faith difference < 0
Long: Hull agreement > 0
Short: Hull agreement < 0