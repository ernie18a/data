Calculation: Buy ratio = (close - low) / (high - low), or 0.5 when high = low
Calculation: Sell ratio = 1 - Buy ratio
Calculation: Volume baseline = simple moving average of volume over a lookback
Long: The prior consecutive run of bars with Buy ratio >= dominance threshold and volume >= Volume baseline × volume multiplier has length >= minimum stack count AND the current bar does not meet both conditions
Short: The prior consecutive run of bars with Sell ratio >= dominance threshold and volume >= Volume baseline × volume multiplier has length >= minimum stack count AND the current bar does not meet both conditions