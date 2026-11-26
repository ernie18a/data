Calculation: M = MACD main line(applied price, fast lookback shorter than slow lookback, signal lookback, T1 bars, current bar still forming)
Calculation: S = Stochastic main line(K lookback, D lookback, slowing, smoothing method, price field, chart bars, current bar still forming)
Long: M[0] < 0 AND M[1] < 0 AND M[2] < 0 AND M[0] > M[1] AND M[1] < M[2] AND S[0] < oversold threshold
Short: M[0] > 0 AND M[1] > 0 AND M[2] > 0 AND M[0] < M[1] AND M[1] > M[2] AND S[0] > overbought threshold
Exit: long, (long stop-loss distance > 0 AND low <= entry price - long stop-loss distance) OR (long take-profit distance > 0 AND high >= entry price + long take-profit distance)
Exit: short, (short stop-loss distance > 0 AND high >= entry price + short stop-loss distance) OR (short take-profit distance > 0 AND low <= entry price - short take-profit distance)