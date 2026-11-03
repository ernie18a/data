Calculation: Candle body ratio = if high − low > 0, abs(close − open) / (high − low); otherwise 0
Calculation: Close position near high = if high − low > 0, (close − low) / (high − low); otherwise 0
Calculation: Close position near low = if high − low > 0, (high − close) / (high − low); otherwise 0
Long: close > open AND candle body ratio ≥ body-ratio threshold AND high − low > ATR × ATR multiplier AND close position near high ≥ close-position threshold AND volume > moving average of volume × volume multiplier
Short: close < open AND candle body ratio ≥ body-ratio threshold AND high − low > ATR × ATR multiplier AND close position near low ≥ close-position threshold AND volume > moving average of volume × volume multiplier