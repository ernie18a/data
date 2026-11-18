Calculation: Overbought state = highest(close < highest(SMA((high + low + close) / 3, smoothing lookback), range lookback) ? 1 : 0, state lookback) == 0
Calculation: Oversold state = sum(close < lowest(SMA((high + low + close) / 3, smoothing lookback), range lookback) ? 1 : 0, state lookback) == state lookback
Calculation: T1 overbought state = Overbought state calculated on T1 still-forming bars and taken onto chart bars
Calculation: T1 oversold state = Oversold state calculated on T1 still-forming bars and taken onto chart bars
Calculation: T1 overbought zone = T1 overbought state OR (T1 overbought state on the prior chart bar AND NOT T1 overbought state on the current chart bar), with the convergence condition latched until the next T1 bar begins
Calculation: T1 oversold zone = T1 oversold state OR (T1 oversold state on the prior chart bar AND NOT T1 oversold state on the current chart bar), with the convergence condition latched until the next T1 bar begins
Long: Oversold state[1] AND NOT Oversold state
Long: T1 is supported AND T1 oversold zone
Long: low > high[2] AND (low - high[2]) / close * 100 >= minimum gap percentage
Short: Overbought state[1] AND NOT Overbought state
Short: T1 is supported AND T1 overbought zone AND NOT T1 oversold zone
Short: high < low[2] AND (low[2] - high) / close * 100 >= minimum gap percentage