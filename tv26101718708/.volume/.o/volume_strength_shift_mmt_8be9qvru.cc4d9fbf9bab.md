Calculation: Volume delta = volume × (2 × (close − low) / (high − low) − 1); 0 when high = low
Calculation: Smoothed volume delta = selected moving average of volume delta
Calculation: Signal threshold = simple moving average of volume over the same lookback as the smoothed volume delta × threshold multiplier
Long: smoothed volume delta > signal threshold AND previous bar’s smoothed volume delta ≤ previous bar’s signal threshold
Short: smoothed volume delta < −signal threshold AND previous bar’s smoothed volume delta ≥ −previous bar’s signal threshold