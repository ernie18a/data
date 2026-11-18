Calculation: smoothed close RSI = SMA(RSI(close, close RSI lookback), close RSI smoothing lookback)
Calculation: smoothed volume RSI = SMA(RSI(volume, volume RSI lookback), volume RSI smoothing lookback)
Long: smoothed close RSI > smoothed close RSI[1]
Short: smoothed close RSI < smoothed close RSI[1]
Long: smoothed close RSI crosses above smoothed volume RSI
Short: smoothed close RSI crosses below smoothed volume RSI