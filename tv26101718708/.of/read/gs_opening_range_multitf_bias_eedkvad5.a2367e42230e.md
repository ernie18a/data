Calculation: Opening-range high and low = the highest high and lowest low of the first N chart bars of the regular session, where N is the greater of one and the floor of the configured opening-range duration divided by the chart-bar duration; reset at each regular-session start and retain the levels until the next start.
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2.
Calculation: Bullish EMA stack = five close EMAs with strictly increasing lookback lengths, each greater than the next longer EMA.
Calculation: Bearish EMA stack = five close EMAs with strictly increasing lookback lengths, each less than the next longer EMA.
Calculation: Bias-timeframe values = close, close EMA, MACD line and MACD signal calculated on the bias timeframe, which may be higher or lower than the chart timeframe or equal to it; for a higher timeframe, historical bars use the last completed bar and the realtime bar uses the bar still forming; for a lower timeframe, use the last available intrabar; for an equal timeframe, use the chart bar.
Long: The current bar is in the regular session AND at least N chart bars have elapsed since the session started AND close crosses above the opening-range high AND (the optional MACD filter is disabled OR the chart-timeframe MACD line > its signal line).
Short: The current bar is in the regular session AND at least N chart bars have elapsed since the session started AND close crosses below the opening-range low AND (the optional MACD filter is disabled OR the chart-timeframe MACD line <= its signal line).
Long: Bullish EMA stack.
Short: Bearish EMA stack.
Long: Close > opening-range midpoint AND chart-timeframe MACD line > its signal line.
Short: Close < opening-range midpoint AND chart-timeframe MACD line <= its signal line.
Long: Bias-timeframe close > its EMA AND bias-timeframe MACD line > its signal line.
Short: Bias-timeframe close <= its EMA AND bias-timeframe MACD line <= its signal line.
Long: Chart-timeframe MACD line > 0 OR MACD signal line > 0 OR MACD histogram > 0.
Short: Chart-timeframe MACD line <= 0 OR MACD signal line <= 0 OR MACD histogram <= 0.