Calculation: Pivot support = the most recent confirmed pivot low, using a parameterized lookback on both sides
Calculation: Pivot distance = (close − pivot support) / ATR
Calculation: SMA distance = (close − chart-timeframe SMA(50)) / ATR
Long: RSI is within its parameterized low and high bounds AND RSI is greater than its prior-bar value AND (pivot distance is between the parameterized allowed-undercut and proximity bounds OR SMA distance is between those bounds) AND (on the higher timeframe, close > SMA(200) AND SMA(50) > SMA(200), or, when SMA(200) is unavailable, close > SMA(50))