Calculation: Pivot high = a bar whose high is the highest in the configured lookback window on both sides; confirmed after the right-side bars on the chart timeframe are complete
Calculation: Pivot low = a bar whose low is the lowest in the configured lookback window on both sides; confirmed after the right-side bars on the chart timeframe are complete
Calculation: Deduplication zone = selected ATR multiple, close-based percentage, or fixed point distance, using values on the pivot confirmation bar
Long: confirmed pivot low AND (no prior accepted pivot low OR absolute difference from the prior accepted pivot low price >= deduplication zone)
Short: confirmed pivot high AND (no prior accepted pivot high OR absolute difference from the prior accepted pivot high price >= deduplication zone)