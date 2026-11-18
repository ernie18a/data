Calculation: long stop = entry-signal bar low - ATR(lookback) * stop multiplier
Calculation: long target = entry-signal bar close + (entry-signal bar close - long stop) * reward-risk multiplier
Calculation: short stop = entry-signal bar high + ATR(lookback) * stop multiplier
Calculation: short target = entry-signal bar close - (short stop - entry-signal bar close) * reward-risk multiplier
Long: close crosses above EMA(close, shorter lookback) AND close > EMA(close, longer lookback, T1), sampled on the previous chart bar (the T1 bar may still be forming) AND datetime is within either configured session window
Short: close crosses below EMA(close, shorter lookback) AND close < EMA(close, longer lookback, T1), sampled on the previous chart bar (the T1 bar may still be forming) AND datetime is within either configured session window
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target