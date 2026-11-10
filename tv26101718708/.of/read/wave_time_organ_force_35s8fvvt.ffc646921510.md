Calculation: Z-score(x) = (x - SMA(x)) / population standard deviation(x), using the same lookback for every component; return 0 when the standard deviation is 0.
Calculation: Organ = EMA(Z-score(change in EMA(close)) + Z-score(ROC(close)) + Z-score(change in OBV) + Z-score(change in ATR multiplied by 1 if close > EMA(close), otherwise -1)).
Calculation: Flow = EMA(Organ); Signal = EMA(Flow), using the same EMA length as Flow.
Calculation: Layer organ values = Organ calculated separately on six timeframes ordered from shorter to longer, using the prior bar in each timeframe. Each timeframe may be higher, lower, or equal to the chart timeframe. Reproduce historical request.security with gaps off and lookahead off: for a higher timeframe, update at the end of its current bar and carry the last returned value between updates; for a lower timeframe, use the last intrabar selected within the chart bar and its preceding lower-timeframe bar; for an equal timeframe, use the preceding bar.
Calculation: Force = EMA(0.10 × first layer organ + 0.13 × second layer organ + 0.17 × third layer organ + 0.18 × fourth layer organ + 0.20 × fifth layer organ + 0.22 × sixth layer organ), using the Flow EMA length.
Calculation: Bull count = number of layer organ values > 0; bear count = number of layer organ values < 0.
Long: Flow crosses above Signal AND Flow > 0 AND Force > 0 AND bull count >= 4.
Short: Flow crosses below Signal AND Flow < 0 AND Force < 0 AND bear count >= 4.
Long: Force > 0 AND bull count >= 4.
Short: Force < 0 AND bear count >= 4.
Long: bull count = 6.
Short: bear count = 6.
Long: bear count < 6 AND Flow > Signal AND Flow > 0.
Short: bull count < 6 AND Flow < Signal AND Flow < 0.
Long: Flow > Force.
Short: Flow <= Force.
Long: bull count >= 4.
Short: bear count >= 4.
Long: Flow crosses above Signal.
Short: Flow crosses below Signal.