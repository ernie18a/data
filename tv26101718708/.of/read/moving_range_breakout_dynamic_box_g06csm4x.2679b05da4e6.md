Calculation: MACD line = shorter-lookback EMA of close minus longer-lookback EMA of close
Calculation: MACD signal line = simple moving average of the MACD line
Calculation: Box high = highest high over the selected lookback of completed bars ending with the bar immediately before the current bar
Calculation: Box low = lowest low over the selected lookback of completed bars ending with the bar immediately before the current bar
Long: close > Box high OR MACD line > MACD signal line AND previous MACD line <= previous MACD signal line
Short: close < Box low OR MACD line < MACD signal line AND previous MACD line >= previous MACD signal line