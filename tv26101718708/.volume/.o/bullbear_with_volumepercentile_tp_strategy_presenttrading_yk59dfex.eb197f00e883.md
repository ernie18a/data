Calculation: Bull Bear Power = (high − EMA(close, EMA lookback)) + (low − EMA(close, EMA lookback))
Calculation: Z-score = (current Bull Bear Power − its SMA over the Z-score lookback) / its standard deviation over the same lookback
Calculation: Volume ratio = current volume / SMA(volume, volume lookback)
Calculation: Close and volume percentiles = percentage of values in the respective rolling lookback, including the current bar, that are less than or equal to the current close or volume
Calculation: Take-profit adjustment factor = average of volume score and close-percentile score; each score uses its high, medium, and low factor when its measure exceeds the corresponding high, medium, or low threshold, and a fallback factor otherwise
Calculation: Take-profit targets = entry price ± ATR × target multiplier × take-profit adjustment factor; use three increasing multipliers for each side
Long: current Z-score > upper threshold AND previous Z-score ≤ upper threshold
Short: current Z-score < negative lower threshold AND previous Z-score ≥ negative lower threshold
Exit: long, current Z-score < 0 AND previous Z-score ≥ 0 OR, when take-profit is enabled, high ≥ any of the three long take-profit targets
Exit: short, current Z-score > 0 AND previous Z-score ≤ 0 OR, when take-profit is enabled, low ≤ any of the three short take-profit targets