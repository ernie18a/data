Calculation: Chart HMA = HMA(close, chart lookback)
Calculation: Chart RSI = RSI(close, chart lookback)
Calculation: SuperTrend line and direction = SuperTrend(factor, lookback)
Calculation: T1 HMA = HMA(close, T1 lookback, calculated on T1 bars, current forming bar, sampled on chart bars)
Calculation: T1 RSI = RSI(close, T1 lookback, calculated on T1 bars, current forming bar, sampled on chart bars)
Long: close crosses above Chart HMA AND Heikin-Ashi close > Heikin-Ashi open AND close > SuperTrend line AND volume >= SMA(volume, lookback) * volume multiplier AND (close > point of control OR close > EMA(close, long-term lookback)) AND Chart RSI < long RSI ceiling AND CCI(close, lookback) > CCI threshold
Long: close crosses above T1 HMA AND T1 RSI > T1 long RSI floor
Short: close crosses below T1 HMA AND T1 RSI < T1 short RSI ceiling
Long: Heikin-Ashi close > Heikin-Ashi open
Short: Heikin-Ashi close <= Heikin-Ashi open
Long: Chart HMA > Chart HMA[1]
Short: Chart HMA <= Chart HMA[1]
Long: SuperTrend direction = -1
Short: SuperTrend direction != -1
Exit: long, close crosses below SuperTrend line OR (close crosses below Chart HMA AND Chart RSI > exit RSI floor)