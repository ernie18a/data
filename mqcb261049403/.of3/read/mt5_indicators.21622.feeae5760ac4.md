Calculation: smoothed PZO = JMA(PZO(close, period), smoothing period, phase parameter)
Calculation: upper floating level = MIN(smoothed PZO, floating lookback, preceding bars) + upper level parameter × (MAX(smoothed PZO, floating lookback, preceding bars) − MIN(smoothed PZO, floating lookback, preceding bars)) / 100
Calculation: lower floating level = MIN(smoothed PZO, floating lookback, preceding bars) + lower level parameter × (MAX(smoothed PZO, floating lookback, preceding bars) − MIN(smoothed PZO, floating lookback, preceding bars)) / 100
Long: smoothed PZO > upper floating level
Short: smoothed PZO < lower floating level