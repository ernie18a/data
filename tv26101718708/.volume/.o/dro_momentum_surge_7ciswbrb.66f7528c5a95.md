Calculation: Volume ratio = volume / moving average of volume over its lookback
Calculation: Close position = (close - low) / (high - low), or 0.5 when high = low
Calculation: Blow-off top = volume ratio ≥ blow-off threshold AND high > low AND (high - max(open, close)) / (high - low) ≥ upper-wick threshold
Calculation: Trailing peak = highest close since entry
Calculation: Effective stop = max(entry price - initial ATR × hard-stop multiplier, trailing peak - current ATR × trail multiplier when (trailing peak - entry price) / entry price ≥ trail activation gain; otherwise entry price - initial ATR × hard-stop multiplier)
Long: flat AND volume ratio ≥ volume surge threshold AND close > open AND close position ≥ minimum close-position threshold AND RSI < maximum entry RSI AND close > EMA AND NOT blow-off top
Exit: long, low ≤ effective stop OR blow-off top