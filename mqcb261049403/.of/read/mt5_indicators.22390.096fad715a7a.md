Calculation: Smoothed open and close = apply the first configurable moving average, then the second configurable moving average, to the chart-bar open and close, respectively.
Calculation: Adjusted candle open = previous adjusted candle close when the absolute difference between chart-bar open and close is at most the gap threshold; otherwise, smoothed open.
Long: Adjusted candle open < smoothed close
Short: Adjusted candle open > smoothed close