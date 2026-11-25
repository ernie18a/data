Calculation: Faster MA = MA(close, shorter lookback)
Calculation: Slower MA = MA(close, longer lookback)
Calculation: Trend = 1 when Trend[1] <= 0 AND Faster MA > Slower MA AND Faster MA[1] < Slower MA[1]; -1 when Trend[1] >= 0 AND Faster MA < Slower MA AND Faster MA[1] > Slower MA[1]; otherwise Trend[1], initially 0
Long: Trend[1] <= 0 AND Faster MA > Slower MA AND Faster MA[1] < Slower MA[1]
Short: Trend[1] >= 0 AND Faster MA < Slower MA AND Faster MA[1] > Slower MA[1]
Long: Trend > 0
Short: Trend < 0