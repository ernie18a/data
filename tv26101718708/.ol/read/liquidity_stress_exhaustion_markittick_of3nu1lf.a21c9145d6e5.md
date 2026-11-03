Calculation: Illiquidity stress z-score = z-score of ln(1 + true range / volume), using volume = 1 when volume is zero or unavailable, over a rolling lookback
Calculation: Trend price = close, optionally smoothed with a recursive Kalman filter (process noise = 1 / length, measurement noise = 1) or LLAMA (SMA(close, length) + (close − close[length]) / 2)
Calculation: R = ATR × stop multiplier
Calculation: Long stop = entry price − R; long TP3 = entry price + R × TP3 multiple
Calculation: Short stop = entry price + R; short TP3 = entry price − R × TP3 multiple
Long: previous completed bar's illiquidity stress z-score > threshold AND trend price < EMA of trend price AND previous bar close < previous bar open AND (if ADX filter is enabled, previous bar ADX >= threshold)
Short: previous completed bar's illiquidity stress z-score > threshold AND trend price > EMA of trend price AND previous bar close > previous bar open AND (if ADX filter is enabled, previous bar ADX >= threshold)
Exit: long, low <= long stop OR high >= long TP3
Exit: short, high >= short stop OR low <= short TP3