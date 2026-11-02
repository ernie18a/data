Calculation: Volume delta = for each completed lower-timeframe bar within the chart bar, calculate volume × (2 × close − high − low) / (high − low), or zero when high = low, and sum the results; if lower-timeframe analysis is disabled or no lower-timeframe bars are available, apply the same calculation to the chart bar.
Calculation: Cumulative volume delta = sum of volume delta over a rolling lookback, available after that many chart bars have elapsed.
Long: close >= open
Short: close < open
Long: volume delta >= 0
Short: volume delta < 0
Long: cumulative volume delta >= 0
Short: cumulative volume delta < 0