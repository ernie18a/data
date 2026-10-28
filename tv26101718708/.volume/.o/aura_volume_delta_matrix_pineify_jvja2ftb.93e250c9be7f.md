Calculation: Volume delta = volume when close > open, minus volume when close < open; zero when close = open
Calculation: Smoothed delta = EMA(volume delta, longer lookback)
Calculation: Signal line = EMA(smoothed delta, shorter lookback)
Long: Smoothed delta crosses above signal line AND smoothed delta > 0
Short: Smoothed delta crosses below signal line AND smoothed delta < 0