Calculation: Timeframe readings = for each of five configurable timeframes, which may be higher than, lower than, or equal to the chart timeframe, use the close, close EMA, and close RSI from the preceding completed timeframe bar. Use the same EMA length across timeframes and the same RSI length across timeframes. For a lower timeframe, select the first intrabar of each chart bar and use its preceding completed lower-timeframe bar.
Calculation: Timeframe score = 0 if any timeframe reading is unavailable; otherwise, add 1 if close > EMA or -1 if close <= EMA, and add 1 if RSI > its midpoint or -1 if RSI <= its midpoint.
Calculation: Bull count = number of timeframes with timeframe score = 2.
Calculation: Bear count = number of timeframes with timeframe score = -2.
Calculation: Composite score = sum of the five timeframe scores.
Long: Any timeframe close > its EMA.
Short: Any timeframe close <= its EMA.
Long: Any available timeframe RSI > its midpoint.
Short: Any available timeframe RSI <= its midpoint.
Long: Any timeframe score = 2.
Short: Any timeframe score = -2.
Long: Bull count >= minimum confluence threshold.
Short: Bear count >= minimum confluence threshold.
Long: Composite score > 2.
Short: Composite score < -2.