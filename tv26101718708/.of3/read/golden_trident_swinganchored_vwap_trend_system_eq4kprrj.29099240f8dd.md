Calculation: Swing direction = +1 if the most recent bar whose high is the rolling highest high over the swing lookback is later than the most recent bar whose low is the rolling lowest low over the swing lookback; otherwise −1
Calculation: Long backstop = close on the long-entry trigger bar − ATR(backstop lookback) × stop-distance multiple
Calculation: Short backstop = close on the short-entry trigger bar + ATR(backstop lookback) × stop-distance multiple
Long: Swing direction = +1
Short: Swing direction = −1
Long: Swing direction = +1 AND (EMA filter disabled OR close > EMA(close, EMA lookback)) AND (chop filter disabled OR highest(high, chop lookback) − lowest(low, chop lookback) > ATR(chop lookback) × range threshold) AND datetime is within the configured date window AND the same entry condition was false on the previous bar AND position is flat or short
Short: short entries enabled AND Swing direction = −1 AND (EMA filter disabled OR close < EMA(close, EMA lookback)) AND (chop filter disabled OR highest(high, chop lookback) − lowest(low, chop lookback) > ATR(chop lookback) × range threshold) AND datetime is within the configured date window AND the same entry condition was false on the previous bar AND position is flat or long
Exit: long, Swing direction = −1
Exit: short, Swing direction = +1
Exit: long, low ≤ Long backstop
Exit: short, high ≥ Short backstop