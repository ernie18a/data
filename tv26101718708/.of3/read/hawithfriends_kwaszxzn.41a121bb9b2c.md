Calculation: Heiken Ashi body = abs(Heiken Ashi close - Heiken Ashi open)
Calculation: Heiken Ashi range = Heiken Ashi high - Heiken Ashi low
Calculation: Heiken Ashi body ratio = 100 * Heiken Ashi body / Heiken Ashi range when range > 0, otherwise 0
Calculation: Heiken Ashi lower wick ratio = 100 * (min(Heiken Ashi open, Heiken Ashi close) - Heiken Ashi low) / Heiken Ashi range when range > 0, otherwise 0
Calculation: Heiken Ashi upper wick ratio = 100 * (Heiken Ashi high - max(Heiken Ashi open, Heiken Ashi close)) / Heiken Ashi range when range > 0, otherwise 0
Calculation: ATR trail = source high when source high > prior trail + ATR(rounded ATR lookback), else source low when source low < prior trail - ATR(rounded ATR lookback), else prior trail; source high/low = close/close, max/min(open, close), or high/low according to the selected source; ATR direction = 1 when trail > prior trail, -1 when trail < prior trail, otherwise prior direction; initial prior trail and direction are 0
Calculation: Price-wave state = trend direction when it differs from prior price-wave state and (rising(close, trend detection lookback) OR falling(close, trend detection lookback)), otherwise prior price-wave state; trend direction adopts close movement (1 when close > close[1], -1 when close < close[1], otherwise 0) when nonzero and different from prior close movement, otherwise prior trend direction; initial prior states are 0
Calculation: Bullish confluence state = Heiken Ashi close >= Heiken Ashi open AND ATR direction > 0 AND price-wave state = 1 AND MACD histogram(close, shorter fast lookback, longer slow lookback, signal lookback) >= 0
Calculation: Bearish confluence state = Heiken Ashi close < Heiken Ashi open AND ATR direction <= 0 AND price-wave state != 1 AND MACD histogram(close, shorter fast lookback, longer slow lookback, signal lookback) < 0
Long: Heiken Ashi close >= Heiken Ashi open
Short: Heiken Ashi close < Heiken Ashi open
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Short: EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback)
Long: Heiken Ashi close >= Heiken Ashi open AND Heiken Ashi body ratio >= minimum body ratio AND Heiken Ashi lower wick ratio <= maximum wick ratio AND Heiken Ashi body >= minimum body size AND the current bar is the first bullish momentum bar after the latest Heiken Ashi bearish-to-bullish change
Short: Heiken Ashi close < Heiken Ashi open AND Heiken Ashi body ratio >= minimum body ratio AND Heiken Ashi upper wick ratio <= maximum wick ratio AND Heiken Ashi body >= minimum body size AND the current bar is the first bearish momentum bar after the latest Heiken Ashi bullish-to-bearish change
Long: ATR direction > 0
Short: ATR direction <= 0
Long: Price-wave state = 1
Short: Price-wave state != 1
Long: MACD histogram(close, shorter fast lookback, longer slow lookback, signal lookback) >= 0
Short: MACD histogram(close, shorter fast lookback, longer slow lookback, signal lookback) < 0
Long: Bullish confluence state = true AND Bullish confluence state[1] = false
Short: Bearish confluence state = true AND Bearish confluence state[1] = false