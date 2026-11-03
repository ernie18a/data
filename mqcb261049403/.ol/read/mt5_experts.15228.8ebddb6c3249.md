Calculation: SilverTrend lower threshold = L + (H − L) × K / 100, where H is the highest high and L is the lowest of the low and close across the current and preceding SSP−1 bars on the configured indicator timeframe; K = 33 − risk parameter
Calculation: SilverTrend upper threshold = H − (H − L) × K / 100
Calculation: SilverTrend trend state = bearish when close is below the lower threshold, bullish when close is above the upper threshold, otherwise retain the prior state; initialize bearish
Long: SilverTrend trend state changes from bearish to bullish on the selected indicator bar (bar index 0 is forming; positive indices are completed; the configured indicator timeframe may be higher or lower than the chart timeframe)
Short: SilverTrend trend state changes from bullish to bearish on the selected indicator bar (bar index 0 is forming; positive indices are completed; the configured indicator timeframe may be higher or lower than the chart timeframe)
Exit: Long, SilverTrend trend state changes from bullish to bearish on the selected indicator bar
Exit: Short, SilverTrend trend state changes from bearish to bullish on the selected indicator bar