Calculation: Prior-window highest high = highest high over the lookback window of completed bars, excluding the current bar
Calculation: Prior-window lowest low = lowest low over the lookback window of completed bars, excluding the current bar
Long: low < prior-window lowest low AND close > prior-window lowest low AND volume > volume moving average × volume multiplier
Short: high > prior-window highest high AND close < prior-window highest high AND volume > volume moving average × volume multiplier
Exit: short, low < prior-window lowest low AND close > prior-window lowest low AND volume > volume moving average × volume multiplier