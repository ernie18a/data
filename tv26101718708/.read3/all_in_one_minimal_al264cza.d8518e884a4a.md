Calculation: summary score = the sum of RSI votes from T1 (shortest timeframe), T2 (middle timeframe), and T3 (longest timeframe); four EMA votes using lookbacks ordered shortest to longest; and one vote each for Stochastic %K > %D, MACD line > signal line, DI+ > DI-, MFI > its midpoint, close > VWAP(hlc3), and OBV > EMA(OBV, OBV lookback); all calculations run on chart bars except RSI, which uses each timeframe's still-forming bar sampled on chart bars; each non-RSI vote contributes the bullish vote weight when its comparison holds and the bearish vote weight otherwise; each RSI vote contributes the bearish vote weight when RSI >= its overbought threshold, otherwise the bullish vote weight when RSI <= its oversold threshold or RSI > its midpoint, and the bearish vote weight otherwise
Long: RSI(close, RSI lookback) from T1's still-forming bar sampled on chart bars <= RSI oversold threshold OR RSI(close, RSI lookback) from T2's still-forming bar sampled on chart bars <= RSI oversold threshold OR RSI(close, RSI lookback) from T3's still-forming bar sampled on chart bars <= RSI oversold threshold
Short: RSI(close, RSI lookback) from T1's still-forming bar sampled on chart bars >= RSI overbought threshold OR RSI(close, RSI lookback) from T2's still-forming bar sampled on chart bars >= RSI overbought threshold OR RSI(close, RSI lookback) from T3's still-forming bar sampled on chart bars >= RSI overbought threshold
Long: close > EMA(close, shortest EMA lookback) OR close > EMA(close, second-shortest EMA lookback) OR close > EMA(close, second-longest EMA lookback) OR close > EMA(close, longest EMA lookback)
Short: close <= EMA(close, shortest EMA lookback) OR close <= EMA(close, second-shortest EMA lookback) OR close <= EMA(close, second-longest EMA lookback) OR close <= EMA(close, longest EMA lookback)
Long: (Stochastic %K(close, high, low, K lookback, smoothing) > Stochastic %D(K, D lookback) AND Stochastic %K <= stochastic overbought threshold) OR (Stochastic %K <= Stochastic %D AND Stochastic %K < stochastic oversold threshold)
Short: (Stochastic %K(close, high, low, K lookback, smoothing) > Stochastic %D(K, D lookback) AND Stochastic %K > stochastic overbought threshold) OR (Stochastic %K <= Stochastic %D AND Stochastic %K >= stochastic oversold threshold)
Long: MACD(close, shorter fast lookback, longer slow lookback, signal lookback).line > MACD(...).signal
Short: MACD(close, shorter fast lookback, longer slow lookback, signal lookback).line <= MACD(...).signal
Long: DI+(ADX lookback) > DI-(ADX lookback)
Short: DI+(ADX lookback) <= DI-(ADX lookback)
Long: MFI(hlc3, MFI lookback) <= MFI oversold threshold OR (MFI(hlc3, MFI lookback) > MFI midpoint AND MFI(hlc3, MFI lookback) < MFI overbought threshold)
Short: MFI(hlc3, MFI lookback) >= MFI overbought threshold OR (MFI(hlc3, MFI lookback) > MFI oversold threshold AND MFI(hlc3, MFI lookback) <= MFI midpoint)
Long: close > VWAP(hlc3)
Short: close <= VWAP(hlc3)
Long: OBV > EMA(OBV, OBV lookback)
Short: OBV <= EMA(OBV, OBV lookback)
Long: summary score >= positive summary threshold
Short: summary score <= negative summary threshold