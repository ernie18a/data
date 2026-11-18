Calculation: VigorIndex = SMA(close - open, lookback) / SMA(high - low, lookback) on T1 bars
Calculation: VigorSignal = (VigorIndex + 2 * VigorIndex[1] + 2 * VigorIndex[2] + VigorIndex[3]) / 6 on T1 bars
Long: VigorIndex[1] > VigorSignal
Short: VigorIndex[1] < VigorSignal