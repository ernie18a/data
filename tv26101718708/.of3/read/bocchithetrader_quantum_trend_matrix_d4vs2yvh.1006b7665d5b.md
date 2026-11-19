Calculation: Trend SMA = SMA(close, trend lookback)
Calculation: MACD line = MACD(close, shorter MACD lookback, longer MACD lookback)
Calculation: MACD signal = EMA(MACD line, MACD signal lookback)
Calculation: RSI signal = RSI(close, RSI signal lookback)
Calculation: Stochastic %K = Stochastic %K(high, low, close, lookback)
Calculation: Stochastic %D = SMA(Stochastic %K, smoothing lookback)
Calculation: Fisher signal = EMA(Fisher Transform(RSI(close, Fisher RSI lookback) / normalization factor), Fisher smoothing lookback)
Calculation: MFI = MFI((high + low + close) / 3, volume, lookback)
Calculation: Bollinger Bands = Bollinger Bands(close, lookback, standard-deviation multiplier)
Calculation: +DI = +DI(high, low, close, DI lookback)
Calculation: -DI = -DI(high, low, close, DI lookback)
Calculation: Fast EMA = EMA(close, shorter EMA lookback)
Calculation: Slow EMA = EMA(close, longer EMA lookback)
Long: close > Trend SMA
Short: close <= Trend SMA
Long: T1 close > T1 Trend SMA, evaluated on T1 bars and sampled on chart bars using the still-forming T1 bar in realtime and the last completed T1 bar historically
Short: T1 close <= T1 Trend SMA, evaluated on T1 bars and sampled on chart bars using the still-forming T1 bar in realtime and the last completed T1 bar historically
Long: T2 close > T2 Trend SMA, evaluated on T2 bars and sampled on chart bars using the still-forming T2 bar in realtime and the last completed T2 bar historically
Short: T2 close <= T2 Trend SMA, evaluated on T2 bars and sampled on chart bars using the still-forming T2 bar in realtime and the last completed T2 bar historically
Long: MACD line > MACD signal
Short: MACD line <= MACD signal
Long: RSI signal >= RSI threshold
Short: RSI signal < RSI threshold
Long: Stochastic %K > Stochastic %D
Short: Stochastic %K <= Stochastic %D
Long: Fisher signal > Fisher threshold
Short: Fisher signal <= Fisher threshold
Long: MFI > MFI threshold
Short: MFI <= MFI threshold
Long: close < lower Bollinger Band
Short: close > upper Bollinger Band
Long: +DI > -DI
Short: +DI <= -DI
Long: Fast EMA > Slow EMA
Short: Fast EMA <= Slow EMA