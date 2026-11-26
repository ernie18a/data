Calculation: Current cloud top = max(Senkou Span A(high, low, Tenkan lookback, Kijun lookback)[cloud displacement - 1], Senkou Span B(high, low, Span B lookback)[cloud displacement - 1])
Calculation: Current cloud bottom = min(Senkou Span A(high, low, Tenkan lookback, Kijun lookback)[cloud displacement - 1], Senkou Span B(high, low, Span B lookback)[cloud displacement - 1])
Calculation: Cloud alignment score = (1 if close > Current cloud top, -1 if close < Current cloud bottom, otherwise 0) + (1 if Tenkan-sen(high, low, Tenkan lookback) > Kijun-sen(high, low, Kijun lookback), otherwise -1) + (1 if Senkou Span A(high, low, Tenkan lookback, Kijun lookback) > Senkou Span B(high, low, Span B lookback), otherwise -1) + (1 if close > close[cloud displacement - 1], otherwise -1)
Calculation: Nearest cloud twist = the largest n from 0 through cloud displacement - 2 where (Senkou Span A[n] > Senkou Span B[n]) differs from (Senkou Span A[n + 1] > Senkou Span B[n + 1]); it exists only if such an n exists and is bullish when Senkou Span A[n] > Senkou Span B[n], otherwise bearish
Long: crossover(Tenkan-sen(high, low, Tenkan lookback), Kijun-sen(high, low, Kijun lookback))
Long: Tenkan-sen(high, low, Tenkan lookback) > Kijun-sen(high, low, Kijun lookback)
Long: Senkou Span A(high, low, Tenkan lookback, Kijun lookback) > Senkou Span B(high, low, Span B lookback)
Long: close > Current cloud top
Long: bar is confirmed AND crossover(close, Current cloud top) AND Cloud alignment score >= alignment threshold
Long: Nearest cloud twist exists and is bullish
Short: crossunder(Tenkan-sen(high, low, Tenkan lookback), Kijun-sen(high, low, Kijun lookback))
Short: Tenkan-sen(high, low, Tenkan lookback) <= Kijun-sen(high, low, Kijun lookback)
Short: Senkou Span A(high, low, Tenkan lookback, Kijun lookback) <= Senkou Span B(high, low, Span B lookback)
Short: close < Current cloud bottom
Short: bar is confirmed AND crossunder(close, Current cloud bottom) AND Cloud alignment score <= -alignment threshold
Short: Nearest cloud twist exists and is bearish