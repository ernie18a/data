Calculation: TimeframeVote(T) = sign(sign(EMA(close, HTF shorter lookback) - EMA(close, HTF longer lookback)) + sign(close - EMA(close, HTF shorter lookback))), evaluated on bars of T
Calculation: VoteSum = TimeframeVote(T1, last completed bar) + TimeframeVote(T2, last completed bar) + TimeframeVote(T3, last completed bar) + TimeframeVote(T4, last completed bar) + TimeframeVote(T5, last completed bar) + TimeframeVote(T6, last completed bar) + (1 if EMA(close, stack shorter lookback) > EMA(close, stack longer lookback), else -1) + (1 if SuperTrend(supertrend ATR lookback, supertrend multiplier) is in uptrend, else -1) + (1 if RSI(close, RSI length) >= RSI midline, else -1) + (1 if MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) >= 0, else -1)
Calculation: Alignment = EMA(VoteSum, smoothing lookback)
Calculation: Bias = 1 if Alignment >= alignment threshold AND (momentum confirm off OR MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > 0 AND RSI(close, RSI length) > RSI midline) AND Bias[1] <= 0; -1 if Alignment <= -alignment threshold AND (momentum confirm off OR MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) < 0 AND RSI(close, RSI length) < RSI midline) AND Bias[1] >= 0; otherwise Bias[1]
Calculation: StopDistance = ATR(trade ATR lookback) * stop multiple, evaluated on the entry bar
Long: Alignment >= alignment threshold AND (momentum confirm off OR MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > 0 AND RSI(close, RSI length) > RSI midline) AND Bias[1] <= 0
Short: Alignment <= -alignment threshold AND (momentum confirm off OR MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) < 0 AND RSI(close, RSI length) < RSI midline) AND Bias[1] >= 0
Exit: long, high >= entry price + first target multiple * StopDistance OR low <= entry price - StopDistance
Exit: short, low <= entry price - first target multiple * StopDistance OR high >= entry price + StopDistance
Long: Alignment crosses above 0
Short: Alignment crosses below 0
Long: Alignment >= 0
Short: Alignment < 0
Long: Bias = 1
Short: Bias = -1