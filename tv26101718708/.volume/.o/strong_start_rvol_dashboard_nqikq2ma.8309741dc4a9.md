Calculation: Current-day relative volume = current forming daily bar's volume / mean volume of the N immediately preceding completed daily bars
Calculation: Current-day change (%) = (current forming daily bar's close / previous completed daily bar's close - 1) × 100
Calculation: RVOL rank = position in the watchlist ordered by current-day relative volume, highest first
Long: (current forming daily bar's open > previous completed daily bar's close AND current forming daily bar's low ≥ previous completed daily bar's close × the gap-hold factor) OR (RVOL rank is within the top selected percentage of the watchlist AND current-day change ≥ the move threshold)
Short: RVOL rank is within the top selected percentage of the watchlist AND current-day change ≤ −the move threshold