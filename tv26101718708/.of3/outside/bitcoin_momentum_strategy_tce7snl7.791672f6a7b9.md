Calculation: caution = close > EMA(close, P1) on T1 AND (highest(high, P2) - low > ATR(P3) * P4 OR close < EMA(close, P1))
Calculation: trailing stop = max(previous trailing stop, highest(P5, P6) - ATR(P3) * (previous-bar caution ? P7 : 1))
Long: close > EMA(close, P1) on T1 AND NOT caution AND time >= P8 AND time <= P9
Exit: long, confirmed chart bar AND (close < trailing stop OR close < EMA(close, P1) on T1) OR P10 enabled AND last confirmed historical bar