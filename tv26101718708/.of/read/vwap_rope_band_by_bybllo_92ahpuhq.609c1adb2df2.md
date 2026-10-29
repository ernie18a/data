Calculation: Threshold = standard deviation of close minus session VWAP over a rolling lookback, scaled by a multiplier
Calculation: Rope = initialize to close; on each chart bar, add sign(close − prior Rope) × max(|close − prior Rope| − Threshold, 0) to prior Rope
Long: Rope > prior Rope AND the last nonzero Rope movement was downward OR close > Rope AND prior close ≤ prior Rope
Short: Rope < prior Rope AND the last nonzero Rope movement was upward OR close < Rope AND prior close ≥ prior Rope