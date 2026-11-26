Calculation: smoothed MFI = SMA(MFI(close, MFI lookback), MFI lookback)
Long: close > SMA(close, long lookback) AND smoothed MFI > smoothed MFI[1] AND smoothed MFI[1] > smoothed MFI[2]
Exit: long, low <= SMA(close, long lookback)
Exit: long, smoothed MFI[1] > smoothed MFI AND smoothed MFI[2] < smoothed MFI[1]