Calculation: Relative volume = volume / its moving average.
Calculation: Adaptive basis = VWMA when relative volume exceeds its threshold; otherwise EMA when ADX exceeds its threshold; otherwise SMA.
Calculation: Dynamic band multiplier = base multiplier × EMA-smoothed weighted average of ADX-, relative-volume-, and RSI-based magnitude factors; weights depend on ADX, relative volume, and RSI distance from 50.
Calculation: Adaptive upper/lower band = adaptive basis ± (dynamic band multiplier × standard deviation of close).
Long: Close crosses above the adaptive upper band
Short: Close crosses below the adaptive lower band