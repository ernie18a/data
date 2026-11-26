Calculation: average_1_now = MA(price source parameter 1, method parameter 1, longest lookback, T1 (shortest timeframe), chart-bar evaluation using the T1 bar at the same numeric shift as the chart bar; T1 shift 0 is still forming)
Calculation: average_1_previous = MA(price source parameter 1, method parameter 1, longest lookback, T1 (shortest timeframe), chart-bar evaluation using the T1 bar one numeric shift older than the chart bar; T1 shift 1 is the last completed bar at chart shift 0)
Calculation: average_2_now = MA(price source parameter 2, method parameter 2, second-longest lookback, T2 (second-shortest timeframe), chart-bar evaluation using the T2 bar at the same numeric shift as the chart bar; T2 shift 0 is still forming)
Calculation: average_2_previous = MA(price source parameter 2, method parameter 2, second-longest lookback, T2 (second-shortest timeframe), chart-bar evaluation using the T2 bar one numeric shift older than the chart bar; T2 shift 1 is the last completed bar at chart shift 0)
Calculation: average_3_now = MA(price source parameter 3, method parameter 3, second-shortest lookback, T3 (second-longest timeframe), chart-bar evaluation using the T3 bar at the same numeric shift as the chart bar; T3 shift 0 is still forming)
Calculation: average_3_previous = MA(price source parameter 3, method parameter 3, second-shortest lookback, T3 (second-longest timeframe), chart-bar evaluation using the T3 bar one numeric shift older than the chart bar; T3 shift 1 is the last completed bar at chart shift 0)
Calculation: average_4_now = MA(price source parameter 4, method parameter 4, shortest lookback, T4 (longest timeframe), chart-bar evaluation using the T4 bar at the same numeric shift as the chart bar; T4 shift 0 is still forming)
Calculation: average_4_previous = MA(price source parameter 4, method parameter 4, shortest lookback, T4 (longest timeframe), chart-bar evaluation using the T4 bar one numeric shift older than the chart bar; T4 shift 1 is the last completed bar at chart shift 0)
Long: average_1_now < average_1_previous
Short: average_1_now >= average_1_previous
Long: average_2_now < average_2_previous
Short: average_2_now >= average_2_previous
Long: average_3_now < average_3_previous
Short: average_3_now >= average_3_previous
Long: average_4_now < average_4_previous
Short: average_4_now >= average_4_previous
Long: average_1_now < price source parameter 1 on the same-index T1 bar
Short: average_1_now >= price source parameter 1 on the same-index T1 bar
Long: average_2_now < price source parameter 2 on the same-index T2 bar
Short: average_2_now >= price source parameter 2 on the same-index T2 bar
Long: average_3_now < price source parameter 3 on the same-index T3 bar
Short: average_3_now >= price source parameter 3 on the same-index T3 bar
Long: average_4_now < price source parameter 1 on the same-index T1 bar
Short: average_4_now >= price source parameter 1 on the same-index T1 bar
Long: average_1_now < average_1_previous AND average_2_now < average_2_previous AND average_3_now < average_3_previous AND average_4_now < average_4_previous
Short: average_1_now >= average_1_previous AND average_2_now >= average_2_previous AND average_3_now >= average_3_previous AND average_4_now >= average_4_previous