Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Relative volume = current volume / average volume, or 1 when average volume is zero
Calculation: Close position = clamp((close - low) / (high - low), 0, 1), or 0 when high equals low
Calculation: Buy pressure score = relative volume × close position × 100
Calculation: Sell pressure score = relative volume × (1 - close position) × 100
Long: relative volume >= extreme-volume threshold AND relative volume >= strong-volume threshold AND buy pressure score > 1.15 × sell pressure score
Short: relative volume >= extreme-volume threshold AND relative volume >= strong-volume threshold AND sell pressure score > 1.15 × buy pressure score