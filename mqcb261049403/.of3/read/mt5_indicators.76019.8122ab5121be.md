Calculation: Bullish FVG size (points) = (low - high[2]) / point
Calculation: Bearish FVG size (points) = (low[2] - high) / point
Calculation: Gap fill percentage = 100 * min(top - bottom, max(0, maximum over later bars of top - low for bullish gaps or high - bottom for bearish gaps)) / (top - bottom); later bars are T1 bars after candle 3 through the current bar
Long: On chart bars, bullish FVG size >= minimum gap size
Short: On chart bars, bearish FVG size >= minimum gap size
Long: On T1 bars, including the bar still forming, bullish FVG size >= minimum gap size AND gap fill percentage < fill threshold
Short: On T1 bars, including the bar still forming, bearish FVG size >= minimum gap size AND gap fill percentage < fill threshold