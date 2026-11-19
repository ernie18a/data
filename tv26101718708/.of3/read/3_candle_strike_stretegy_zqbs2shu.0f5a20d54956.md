Calculation: smoothed regression slope = EMA(LinReg(close, regression lookback) - LinReg(close, regression lookback)[1], slope smoothing lookback)
Long: each of the preceding pattern-length bars has close <= open, and current close > open[1]
Short: each of the preceding pattern-length bars has close >= open, and current close < open[1]
Long: pattern-entry switch enabled AND within entry session AND each of the preceding pattern-length bars has close <= open AND current close > open[1] AND SMMA(close, short lookback) > SMMA(close, medium lookback) AND SMMA(close, short lookback) > SMMA(close, short lookback)[1] AND abs(smoothed regression slope) > regression threshold
Short: pattern-entry switch enabled AND within entry session AND each of the preceding pattern-length bars has close >= open AND current close < open[1] AND SMMA(close, short lookback) < SMMA(close, medium lookback) AND SMMA(close, short lookback) < SMMA(close, short lookback)[1] AND abs(smoothed regression slope) > regression threshold
Long: crossover-entry switch enabled AND within entry session AND SMMA(close, short lookback) < SMMA(close, long lookback) AND SMMA(close, medium lookback) < SMMA(close, long lookback) AND EMA(close, EMA lookback) > SMMA(close, short lookback) AND each of the preceding pattern-length bars has close <= open AND current close > open[1] AND bars since EMA(close, EMA lookback) crosses SMMA(close, short lookback) < crossover recency lookback
Short: crossover-entry switch enabled AND within entry session AND SMMA(close, short lookback) > SMMA(close, long lookback) AND SMMA(close, medium lookback) > SMMA(close, long lookback) AND EMA(close, EMA lookback) < SMMA(close, short lookback) AND each of the preceding pattern-length bars has close >= open AND current close < open[1] AND bars since EMA(close, EMA lookback) crosses SMMA(close, short lookback) < crossover recency lookback
Exit: long, each of the preceding pattern-length bars has close >= open AND current close < open[1]
Exit: short, each of the preceding pattern-length bars has close <= open AND current close > open[1]
Calculation: initial long stop = Lowest(low, stop lookback) - ATR(ATR lookback, T1, current T1 bar still forming; calculated on T1 bars and sampled on chart bars) × ATR offset percentage
Calculation: initial short stop = Highest(high, stop lookback) + ATR(ATR lookback, T1, current T1 bar still forming; calculated on T1 bars and sampled on chart bars) × ATR offset percentage
Calculation: long stop = initial long stop on the entry bar; before the long target is first crossed, min(initial long stop on the entry bar, Lowest(low, stop lookback)); after it is first crossed, max(low[1], long stop[1])
Calculation: short stop = initial short stop on the entry bar; before the short target is first crossed, max(initial short stop on the entry bar, Highest(high, stop lookback)); after it is first crossed, min(high[1], short stop[1])
Calculation: long target = entry price + (entry price - long stop) × reward-risk parameter
Calculation: short target = entry price - (short stop - entry price) × reward-risk parameter
Exit: long, low <= long stop OR (after the entry bar AND high >= long target)
Exit: short, high >= short stop OR (after the entry bar AND low <= short target)
Exit: long, outside entry session
Exit: short, outside entry session
Exit: long, datetime reaches the configured close time on a configured close weekday
Exit: short, datetime reaches the configured close time on a configured close weekday