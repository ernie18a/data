Calculation: Relative volume = current bar volume divided by the mean volume over the lookback ending at the current bar
Calculation: Candle body percentage = |close - open| / (high - low) × 100; use 0 when high = low
Calculation: Close position percentage = (close - low) / (high - low) × 100; use 50 when high = low
Long: volume > 0 AND average volume > 0 AND relative volume ≥ high-volume threshold AND close > open AND candle body percentage ≥ minimum body percentage AND close position percentage ≥ close-strength percentage
Short: volume > 0 AND average volume > 0 AND relative volume ≥ high-volume threshold AND close < open AND candle body percentage ≥ minimum body percentage AND close position percentage ≤ 100 − close-strength percentage