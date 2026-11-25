Calculation: Fast MA = MA(close, shorter lookback)
Calculation: Slow MA = MA(close, longer lookback)
Calculation: Standard deviation = StdDev(close, lookback)
Long: Fast MA[0] > Slow MA[0] AND close[1] > open[1] AND close[1] > Slow MA[0] AND Standard deviation[0] > Standard deviation[1]
Short: Fast MA[0] < Slow MA[0] AND close[1] < open[1] AND close[1] < Slow MA[0] AND Standard deviation[0] > Standard deviation[1]