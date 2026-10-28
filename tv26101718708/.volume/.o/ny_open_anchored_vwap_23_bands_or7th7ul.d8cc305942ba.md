Calculation: NY-open anchored VWAP = cumulative volume-weighted average of each bar’s (high + low + close) / 3 from the current day’s New York session open through the current bar
Calculation: VWMA = volume-weighted moving average of each bar’s (high + low + close) / 3 over a lookback window
Long: VWMA > NY-open anchored VWAP AND previous bar’s VWMA <= previous bar’s NY-open anchored VWAP
Short: VWMA < NY-open anchored VWAP AND previous bar’s VWMA >= previous bar’s NY-open anchored VWAP