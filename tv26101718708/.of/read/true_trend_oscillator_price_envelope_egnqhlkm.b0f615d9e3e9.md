Calculation: Smoothed Stoch ATR = clamp the Rational Quadratic Kernel smoothing of the simple moving average of ATR’s stochastic value to 0–100
Calculation: Bull Trend = sqrt(RSI(close) × Smoothed Stoch ATR)
Calculation: Bear Trend = sqrt((100 − RSI(close)) × Smoothed Stoch ATR)
Long: Bull Trend > Bear Trend AND min(Bull Trend, Bear Trend) > active threshold OR Bull Trend > 80
Short: Bear Trend > Bull Trend AND min(Bull Trend, Bear Trend) > active threshold OR Bear Trend > 80