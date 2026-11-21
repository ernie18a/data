Calculation: StdPivot = (High(T1, last completed bar) + Low(T1, last completed bar) + Close(T1, last completed bar)) / 3
Calculation: StdPivotR1 = 2 * StdPivot - Low(T1, last completed bar)
Calculation: StdPivotR2 = StdPivot + High(T1, last completed bar) - Low(T1, last completed bar)
Calculation: StdPivotS1 = 2 * StdPivot - High(T1, last completed bar)
Calculation: StdPivotS2 = StdPivot - High(T1, last completed bar) + Low(T1, last completed bar)
Calculation: StdPivotS3 = Low(T1, last completed bar) - 2 * (High(T1, last completed bar) - StdPivot)
Calculation: BiasScore(T, last completed bar) = sum of six terms, each +1 if true and -1 if false, evaluated on T bars: close > EMA(close, shorter EMA lookback); close > EMA(close, longer EMA lookback); EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback); RSI(close, RSI lookback) > RSI midline; MACD line(close, shorter MACD lookback, longer MACD lookback) > 0; close > ParabolicSAR(SAR parameters)
Long: low <= StdPivotS2 AND close > StdPivotS2
Long: RSI(close, RSI lookback) > RSI midline AND RSI(close, RSI lookback) <= RSI overbought level
Long: RSI(close, RSI lookback) < RSI oversold level
Long: MACD line(close, shorter MACD lookback, longer MACD lookback) > MACD signal line(close, shorter MACD lookback, longer MACD lookback, MACD signal lookback)
Long: +DI(DMI lookback) > -DI(DMI lookback) AND ADX(DMI lookback) > ADX trend level
Long: close > ParabolicSAR(SAR parameters)
Long: close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Long: close > EMA(close, long EMA lookback)
Long: close > StdPivot
Long: BiasScore(T1, last completed bar) >= bias threshold
Long: BiasScore(T2, last completed bar) >= bias threshold
Long: BiasScore(T3, last completed bar) >= bias threshold
Long: BiasScore(T4, last completed bar) >= bias threshold
Short: high >= StdPivotR1 AND close < StdPivotR1
Short: RSI(close, RSI lookback) > RSI overbought level
Short: RSI(close, RSI lookback) >= RSI oversold level AND RSI(close, RSI lookback) <= RSI midline
Short: MACD line(close, shorter MACD lookback, longer MACD lookback) <= MACD signal line(close, shorter MACD lookback, longer MACD lookback, MACD signal lookback)
Short: +DI(DMI lookback) <= -DI(DMI lookback) AND ADX(DMI lookback) > ADX trend level
Short: close <= ParabolicSAR(SAR parameters)
Short: close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Short: close <= EMA(close, long EMA lookback)
Short: close <= StdPivot
Short: BiasScore(T1, last completed bar) <= -bias threshold
Short: BiasScore(T2, last completed bar) <= -bias threshold
Short: BiasScore(T3, last completed bar) <= -bias threshold
Short: BiasScore(T4, last completed bar) <= -bias threshold
Exit: short, high >= StdPivotR2
Exit: short, low <= StdPivotS1
Exit: short, low <= StdPivotS2
Exit: short, low <= StdPivotS3
Exit: long, low <= StdPivotS3 - stop ATR multiplier * ATR(ATR lookback)
Exit: long, high >= StdPivot
Exit: long, high >= StdPivotR1
Exit: long, high >= StdPivotR2