Calculation: volume average = SMA(volume, volume lookback)
Calculation: trend average = selected EMA or SMA(trend source, trend lookback)
Long: trend source > trend average AND (volume >= volume average × noise multiplier OR volume > volume average)
Short: trend source <= trend average AND (volume >= volume average × noise multiplier OR volume > volume average)