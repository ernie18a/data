Calculation: available swing low = latest confirmed PivotLow(low, pivot lookback, pivot lookback) since the previous bullish sweep, or none
Calculation: available swing high = latest confirmed PivotHigh(high, pivot lookback, pivot lookback) since the previous bearish sweep, or none
Long: low < available swing low AND close > available swing low
Short: high > available swing high AND close < available swing high
Long: low > high[2] AND close[1] > open[1]
Short: high < low[2] AND close[1] < open[1]