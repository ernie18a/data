Calculation: Close position within bar = (close - low) / (high - low)
Calculation: Normalized volume = volume / its moving average, capped at 3
Calculation: Normalized flow score = normalize over a rolling lookback the product of the bar’s absolute body-to-range ratio and normalized volume to the range 0–1
Long: close < WMA AND close position > 0.65 AND close > open AND normalized volume > 1.2 AND normalized flow score > 0.5
Long: close > WMA AND previous close <= previous WMA
Short: close > WMA AND close position < 0.35 AND close < open AND normalized volume > 1.2 AND normalized flow score > 0.5
Short: close <= WMA AND previous close > previous WMA