Calculation: Volume baseline = simple moving average of volume over a lookback
Calculation: Lower-wick ratio = (min(open, close) - low) / (high - low)
Calculation: Upper-wick ratio = (high - max(open, close)) / (high - low)
Calculation: Confirmed swing low/high = low/high that is the lowest/highest over equal lookback periods on both sides; confirm after the right-side period completes
Long: confirmed bar AND (confirmed swing low OR lower-wick ratio ≥ threshold OR (volume ≥ volume baseline × multiple AND close ≥ open))
Short: confirmed bar AND (confirmed swing high OR upper-wick ratio ≥ threshold OR (volume ≥ volume baseline × multiple AND close < open))