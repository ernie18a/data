Calculation: Delta = half of volume when close > open, negative half of volume when close < open, otherwise 0
Calculation: CVD = cumulative sum of Delta
Long: current Delta > 0 AND previous Delta <= 0 AND CVD > simple moving average of CVD
Short: current Delta < 0 AND previous Delta >= 0 AND CVD < simple moving average of CVD