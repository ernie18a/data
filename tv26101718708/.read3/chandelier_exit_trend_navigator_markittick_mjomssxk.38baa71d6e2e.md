Calculation: KalmanFilter(src, len) = e, where e = e[1] + K * (src - e[1]), K = Pp / (Pp + R), Pp = P[1] + Qs / len, P = (1 - K) * Pp, with e[1] = src and P[1] = P0 on the first bar
Calculation: SlopeAdjustedSMA(src, len) = SMA(src, len) + (src - src[len]) / len * (len / D)
Calculation: AdaptiveSrc = close if adaptive filter is none; KalmanFilter(close, adaptive length) if adaptive filter is Kalman; SlopeAdjustedSMA(close, adaptive length) if adaptive filter is slope-adjusted
Calculation: ChandelierLong = Highest(AdaptiveSrc if use close extremes else high, ATR length) - ATR(ATR length) * ATR multiplier
Calculation: ChandelierShort = Lowest(AdaptiveSrc if use close extremes else low, ATR length) + ATR(ATR length) * ATR multiplier
Calculation: Trend = 1 if close > ChandelierShort[1]; -1 if close < ChandelierLong[1]; Trend[1] otherwise
Long: Trend[1] = -1 AND Trend = 1 AND (HTF filter off OR close > EMA(close, HTF length, T1, last completed bar)) AND (ADX filter off OR ADX(ADX length) >= ADX threshold)
Short: Trend[1] = 1 AND Trend = -1 AND (HTF filter off OR close < EMA(close, HTF length, T1, last completed bar)) AND (ADX filter off OR ADX(ADX length) >= ADX threshold)
Long: Trend = 1
Short: Trend = -1
Long: HTF filter on AND close > EMA(close, HTF length, T1, last completed bar)
Short: HTF filter on AND close < EMA(close, HTF length, T1, last completed bar)