Calculation: PriceRSIMA = SMA(RSI(close, price RSI lookback), price MA lookback)
Long: PriceRSIMA > PriceRSIMA[1]
Short: PriceRSIMA < PriceRSIMA[1]
Long: PriceRSIMA crosses above SMA(RSI(volume, volume RSI lookback), volume MA lookback)
Short: PriceRSIMA crosses below SMA(RSI(volume, volume RSI lookback), volume MA lookback)