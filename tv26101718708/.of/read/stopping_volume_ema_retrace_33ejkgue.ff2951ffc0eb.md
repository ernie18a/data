Calculation: Upper extension = EMA of close × (1 + minimum extension distance / 100)
Calculation: Lower extension = EMA of close × (1 − minimum extension distance / 100)
Calculation: Average volume = simple average of volume on the preceding lookback bars
Calculation: Candle range = high − low
Calculation: Lower wick = min(open, close) − low
Calculation: Upper wick = high − max(open, close)
Calculation: Lower wick percentage = lower wick / candle range × 100 (0 if range is zero)
Calculation: Upper wick percentage = upper wick / candle range × 100 (0 if range is zero)
Calculation: Close position = (close − low) / candle range × 100 (50 if range is zero)
Long: low ≤ lower extension AND average volume > 0 AND volume ≥ average volume × high-volume multiplier AND lower wick percentage ≥ minimum rejection-wick percentage AND close position ≥ minimum close recovery percentage AND (lower wick > upper wick if wick-dominance filter is enabled)
Short: high ≥ upper extension AND average volume > 0 AND volume ≥ average volume × high-volume multiplier AND upper wick percentage ≥ minimum rejection-wick percentage AND close position ≤ 100 − minimum close recovery percentage AND (upper wick > lower wick if wick-dominance filter is enabled)