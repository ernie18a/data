Calculation: Chikou momentum = (close - close[displacement - 1]) / ATR(atr lookback)
Calculation: Cloud top = MAX(Senkou Span A(shorter lookback, longer lookback), Senkou Span B(longest lookback))[displacement - 1]
Calculation: Cloud bottom = MIN(Senkou Span A(shorter lookback, longer lookback), Senkou Span B(longest lookback))[displacement - 1]
Calculation: Cloud distance = (close - Cloud top) / ATR(atr lookback) if close > Cloud top; (close - Cloud bottom) / ATR(atr lookback) if close < Cloud bottom; 0 otherwise
Calculation: T1 Cloud top = Cloud top evaluated on T1 bars, last completed T1 bar
Calculation: T1 Cloud bottom = Cloud bottom evaluated on T1 bars, last completed T1 bar
Long: Tenkan-sen(shorter lookback) crosses above Kijun-sen(longer lookback) AND close > open AND Cloud distance != 0 AND Chikou momentum > 0 AND abs(Chikou momentum) >= min Chikou momentum AND (not HTF filter OR T1 close[1] > T1 Cloud top[1])
Long: Tenkan-sen(shorter lookback) crosses above Kijun-sen(longer lookback) AND (close <= open OR Cloud distance = 0 OR Chikou momentum <= 0 OR abs(Chikou momentum) < min Chikou momentum OR (HTF filter AND T1 close[1] <= T1 Cloud top[1]))
Long: close crosses above Cloud top AND close > open AND abs(Cloud distance) >= min cloud distance AND Chikou momentum > 0 AND abs(Chikou momentum) >= min Chikou momentum AND (not HTF filter OR T1 close[1] > T1 Cloud top[1])
Long: close crosses above Cloud top AND (close <= open OR abs(Cloud distance) < min cloud distance OR Chikou momentum <= 0 OR abs(Chikou momentum) < min Chikou momentum OR (HTF filter AND T1 close[1] <= T1 Cloud top[1]))
Long: Senkou Span A(shorter lookback, longer lookback) crosses above Senkou Span B(longest lookback)
Long: T1 close[1] > T1 Cloud top[1]
Short: Tenkan-sen(shorter lookback) crosses below Kijun-sen(longer lookback) AND close < open AND Cloud distance != 0 AND Chikou momentum < 0 AND abs(Chikou momentum) >= min Chikou momentum AND (not HTF filter OR T1 close[1] < T1 Cloud bottom[1])
Short: Tenkan-sen(shorter lookback) crosses below Kijun-sen(longer lookback) AND (close >= open OR Cloud distance = 0 OR Chikou momentum >= 0 OR abs(Chikou momentum) < min Chikou momentum OR (HTF filter AND T1 close[1] >= T1 Cloud bottom[1]))
Short: close crosses below Cloud bottom AND close < open AND abs(Cloud distance) >= min cloud distance AND Chikou momentum < 0 AND abs(Chikou momentum) >= min Chikou momentum AND (not HTF filter OR T1 close[1] < T1 Cloud bottom[1])
Short: close crosses below Cloud bottom AND (close >= open OR abs(Cloud distance) < min cloud distance OR Chikou momentum >= 0 OR abs(Chikou momentum) < min Chikou momentum OR (HTF filter AND T1 close[1] >= T1 Cloud bottom[1]))
Short: Senkou Span A(shorter lookback, longer lookback) crosses below Senkou Span B(longest lookback)
Short: T1 close[1] < T1 Cloud bottom[1]