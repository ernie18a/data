Calculation: Higher-timeframe EMA = EMA(close, EMA lookback, T1, last completed bar), sampled on chart bars
Calculation: Caution = close > Higher-timeframe EMA AND (highest(high, caution swing lookback) - low > ATR(ATR lookback) * caution threshold OR close < EMA(close, EMA lookback))
Calculation: Trailing stop = maximum of the prior trailing stop and highest(trail source, trailing lookback) - (previous chart bar Caution ? ATR(ATR lookback) * ratchet multiplier : ATR(ATR lookback)); initialize to this candidate when there is no prior trailing stop
Long: position is flat AND close > Higher-timeframe EMA AND highest(high, caution swing lookback) - low <= ATR(ATR lookback) * caution threshold AND close >= EMA(close, EMA lookback) AND datetime is between the start-time and end-time parameters
Exit: long, close < Trailing stop OR close < Higher-timeframe EMA
Calculation: caution = close > EMA(close, P1) on T1 AND (highest(high, P2) - low > ATR(P3) * P4 OR close < EMA(close, P1))
Calculation: trailing stop = max(previous trailing stop, highest(P5, P6) - ATR(P3) * (previous-bar caution ? P7 : 1))
Long: close > EMA(close, P1) on T1 AND NOT caution AND time >= P8 AND time <= P9
Exit: long, confirmed chart bar AND (close < trailing stop OR close < EMA(close, P1) on T1) OR P10 enabled AND last confirmed historical bar