Calculation: Delta = (close > open ? volume : volume * 0.5) - (close < open ? volume : volume * 0.5)
Calculation: CVD = cumulative sum of Delta, initialized at zero
Long: Delta crosses above 0 AND CVD > SMA(CVD, lookback)
Short: Delta crosses below 0 AND CVD < SMA(CVD, lookback)