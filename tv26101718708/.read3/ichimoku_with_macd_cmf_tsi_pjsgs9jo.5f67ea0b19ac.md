Calculation: Ichimoku midpoint(lookback) = (highest(high, lookback) + lowest(low, lookback)) / 2
Calculation: Tenkan-Sen = Ichimoku midpoint(Tenkan lookback)
Calculation: Kijun-Sen = Ichimoku midpoint(Kijun lookback)
Calculation: Senkou Span A = (Tenkan-Sen + Kijun-Sen) / 2
Calculation: Senkou Span B = Ichimoku midpoint(Senkou Span B lookback)
Calculation: Cloud top = max(Senkou Span A[Senkou Span offset - 1], Senkou Span B[Senkou Span offset - 1])
Calculation: Cloud bottom = min(Senkou Span A[Senkou Span offset - 1], Senkou Span B[Senkou Span offset - 1])
Long: Tenkan-Sen > Kijun-Sen AND close > close[Chikou offset - 1] AND close > Cloud top AND MACD histogram(source, fast lookback, slow lookback, signal lookback, oscillator MA type, signal MA type) > 0 AND CMF(CMF lookback) > CMF threshold AND TSI(first smoothing lookback, second smoothing lookback) > 0 AND long-entry option enabled
Short: Tenkan-Sen < Kijun-Sen AND close < close[Chikou offset - 1] AND close < Cloud bottom AND MACD histogram(source, fast lookback, slow lookback, signal lookback, oscillator MA type, signal MA type) < 0 AND CMF(CMF lookback) < -CMF threshold AND TSI(first smoothing lookback, second smoothing lookback) < 0 AND short-entry option enabled
Exit: long, Tenkan-Sen < Kijun-Sen AND close < close[Chikou offset - 1] AND close < Cloud bottom AND MACD histogram(source, fast lookback, slow lookback, signal lookback, oscillator MA type, signal MA type) < 0 AND CMF(CMF lookback) < -CMF threshold AND TSI(first smoothing lookback, second smoothing lookback) < 0 AND short-entry option disabled
Exit: short, Tenkan-Sen > Kijun-Sen AND close > close[Chikou offset - 1] AND close > Cloud top AND MACD histogram(source, fast lookback, slow lookback, signal lookback, oscillator MA type, signal MA type) > 0 AND CMF(CMF lookback) > CMF threshold AND TSI(first smoothing lookback, second smoothing lookback) > 0 AND long-entry option disabled