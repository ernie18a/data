Calculation: Dir(tf, n) = +1 if close > EMA(close, n) else -1, both computed on timeframe tf; for a tf higher than the chart timeframe use the bar still forming, for a tf lower than the chart timeframe use its last bar within the chart bar
Calculation: Score = sum over a set of timeframes (from lower to higher than the chart timeframe) and EMA lengths (short to long) of weight * Dir(tf, n); weight increases with higher timeframe and with longer EMA length, so higher-timeframe, long-EMA terms dominate
Calculation: Main = the chosen main trading timeframe; Trigger = a timeframe lower than Main; Gravity1 and Gravity2 = two timeframes higher than Main
Long: Score > 0 AND Dir(Main, short EMA) = 1 AND Dir(Main, mid EMA) = 1 AND Dir(Trigger, short EMA) = 1
Long: Dir(Gravity1, mid EMA) = 1 AND Dir(Gravity2, mid EMA) = 1 AND Dir(Main, short EMA) = 1 AND Dir(Trigger, short EMA) = 1
Short: Score < 0 AND Dir(Main, short EMA) = -1 AND Dir(Main, mid EMA) = -1 AND Dir(Trigger, short EMA) = -1
Short: Dir(Gravity1, mid EMA) = -1 AND Dir(Gravity2, mid EMA) = -1 AND Dir(Main, short EMA) = -1 AND Dir(Trigger, short EMA) = -1