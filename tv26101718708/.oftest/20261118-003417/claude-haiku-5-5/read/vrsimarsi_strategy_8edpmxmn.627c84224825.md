Calculation: MaRsiPrice = SMA(RSI(close, price RSI lookback), price MA lookback)
Long: MaRsiPrice > MaRsiPrice[1]
Short: MaRsiPrice < MaRsiPrice[1]
Long: MaRsiPrice - SMA(RSI(volume, volume RSI lookback), volume MA lookback) crosses above 0
Short: MaRsiPrice - SMA(RSI(volume, volume RSI lookback), volume MA lookback) crosses below 0