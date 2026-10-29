Calculation: Reverse-close threshold = use chart-timeframe bars, with the last completed bar: calculate 2 × (prior Heikin Ashi open + prior Heikin Ashi close) − (open + high + low) of the bar; if the result is below that bar’s low, average the result and low; if above that bar’s high, average the result and high.
Calculation: Smoothed reverse-close threshold = apply the selected moving average to the reverse-close threshold over its lookback, using chart-timeframe bars and the last completed bar.
Long: chart-timeframe close crosses above the smoothed reverse-close threshold
Short: chart-timeframe close crosses below the smoothed reverse-close threshold
Exit: Long, low ≤ entry price × (1 − long stop-loss percentage)
Exit: Short, high ≥ entry price × (1 + short stop-loss percentage)