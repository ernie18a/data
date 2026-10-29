Calculation: Strat candle type = on each configured timeframe, compare the current still-forming bar’s high and low with the previous completed bar’s high and low: 2U if high > previous high and low >= previous low; 2D if low < previous low and high <= previous high; 1 if high <= previous high and low >= previous low; 3 if high > previous high and low < previous low. Use configured timeframes both higher and lower than the chart timeframe.
Calculation: Bullish alignment count = number of enabled configured timeframes with Strat candle type 2U.
Calculation: Bearish alignment count = number of enabled configured timeframes with Strat candle type 2D.
Long: Bullish alignment count >= minimum alignment threshold
Short: Bearish alignment count >= minimum alignment threshold