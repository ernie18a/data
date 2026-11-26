Calculation: Bullish FVG = low > high[2] AND close[1] > high[2]
Calculation: Bearish FVG = high < low[2] AND close[1] < low[2]
Long: Bullish FVG AND low > Highest(high, trend lookback)[2]
Long: Bullish FVG AND low > Highest(high, trend lookback)[2] AND volume > SMA(volume, volume lookback) * volume threshold
Short: Bearish FVG AND high < Lowest(low, trend lookback)[2]
Short: Bearish FVG AND high < Lowest(low, trend lookback)[2] AND volume > SMA(volume, volume lookback) * volume threshold
Exit: long, low <= entry price * (1 - stop-loss percentage / 100) OR high >= entry price * (1 + take-profit percentage / 100)
Exit: short, high >= entry price * (1 + stop-loss percentage / 100) OR low <= entry price * (1 - take-profit percentage / 100)