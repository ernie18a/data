Calculation: reverse close = if Heikin-Ashi close[1] > Heikin-Ashi open[1], (low + B) / 2; if Heikin-Ashi close[1] < Heikin-Ashi open[1], (high + B) / 2; otherwise B, where B = 2 × (Heikin-Ashi open[1] + Heikin-Ashi close[1]) − high − low − open; use chart-timeframe values on chart bars, selected from the current forming bar when repaint is enabled or the last completed bar otherwise
Calculation: smoothed reverse close = selected SMA, EMA, HMA, VWMA, or RMA(reverse close, smoothing lookback)
Long: on chart bars, the selected chart-timeframe close crosses above smoothed reverse close
Short: on chart bars, the selected chart-timeframe close crosses below smoothed reverse close
Exit: long, low ≤ entry price × (1 − long stop-loss percentage / 100)
Exit: short, high ≥ entry price × (1 + short stop-loss percentage / 100)