Calculation: Timeframe RSI = RSI of close with the same lookback across enabled timeframes; for a higher timeframe use the last completed bar on historical chart bars and the forming bar in real time; for a lower timeframe use the last intrabar within the chart bar, completed historically and possibly forming in real time; for the chart timeframe use the current bar.
Calculation: Bullish count = number of enabled timeframes whose timeframe RSI, replacing unavailable values with 0, is >= the bullish RSI threshold.
Calculation: Bearish count = number of enabled timeframes whose timeframe RSI, replacing unavailable values with 50, is <= the bearish RSI threshold.
Long: Bullish count >= minimum alignment count.
Short: Bearish count >= minimum alignment count AND bullish count < minimum alignment count.
Long: (Bullish count >= minimum alignment count OR bearish count >= minimum alignment count) AND any enabled timeframe RSI >= the bullish RSI threshold.
Short: (Bullish count >= minimum alignment count OR bearish count >= minimum alignment count) AND any enabled timeframe RSI <= the bearish RSI threshold AND that same timeframe RSI < the bullish RSI threshold.