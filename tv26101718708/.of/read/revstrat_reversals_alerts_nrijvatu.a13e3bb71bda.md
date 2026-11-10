Calculation: Inside bar at index i = high[i] < high[i+1] AND low[i] > low[i+1], where index 0 is the current chart bar and increasing indices denote earlier chart bars.
Calculation: Up bar at index i = high[i] > high[i+1] AND low[i] >= low[i+1].
Calculation: Down bar at index i = low[i] < low[i+1] AND high[i] <= high[i+1].
Calculation: Outside bar at index i = high[i] > high[i+1] AND low[i] < low[i+1].
Calculation: Timeframe state = open and close requested on each of eight progressively longer timeframes. For a higher timeframe, use the last completed bar on historical chart bars and the forming bar in real time; for the chart timeframe, use its current bar; for a lower timeframe, use the last available intrabar. Evaluate only timeframes eligible for display on the chart.
Long: Outside bar at index 1 AND up bar at index 0.
Long: Inside bar at index 2 AND down bar at index 1 AND up bar at index 0.
Long: Down bar at index 1 AND up bar at index 0.
Long: Outside bar at index 0 AND close[0] > high[1].
Long: Close >= open on any eligible timeframe state.
Long: Close >= open on each of three selected progressively longer timeframe states AND the same three-way condition was false on the preceding chart bar.
Short: Outside bar at index 1 AND down bar at index 0.
Short: Inside bar at index 2 AND up bar at index 1 AND down bar at index 0.
Short: Up bar at index 1 AND down bar at index 0.
Short: Outside bar at index 0 AND close[0] < low[1].
Short: Close < open on any eligible timeframe state.
Short: Close < open on each of three selected progressively longer timeframe states AND the same three-way condition was false on the preceding chart bar.