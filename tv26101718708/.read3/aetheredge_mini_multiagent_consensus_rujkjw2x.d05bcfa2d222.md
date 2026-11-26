Calculation: Trend vote = +1 when EMA(close, shorter trend lookback) > EMA(close, longer trend lookback), -1 when EMA(close, shorter trend lookback) < EMA(close, longer trend lookback), otherwise 0
Calculation: Momentum vote = +1 when RSI(close, momentum lookback) > bullish threshold, -1 when RSI(close, momentum lookback) < bearish threshold, otherwise 0
Calculation: Volume vote = +1 when volume z-score >= volume threshold and close > open, -1 when volume z-score >= volume threshold and close < open, otherwise 0, where volume z-score = (volume - SMA(volume, volume baseline lookback)) / stdev(volume, volume baseline lookback), or 0 when the standard deviation is 0
Calculation: Each agent weight starts at an initial-weight parameter and, after the outcome horizon, updates as prior weight + learning-rate parameter × (win - prior weight), where win = 1 if vote direction × (close on outcome bar - close on vote bar) >= required-move parameter × ATR(high, low, close, ATR lookback) on the outcome bar, otherwise 0
Calculation: Weighted vote sum = trend vote × (learned trend weight if learned weights are enabled, otherwise 1) + momentum vote × (learned momentum weight if learned weights are enabled, otherwise 1) + volume vote × (learned volume weight if learned weights are enabled, otherwise 1)
Calculation: Positive vote count = count of trend vote, momentum vote, and volume vote equal to +1
Calculation: Negative vote count = count of trend vote, momentum vote, and volume vote equal to -1
Long: Trend vote = +1
Short: Trend vote = -1
Long: Momentum vote = +1
Short: Momentum vote = -1
Long: Volume vote = +1
Short: Volume vote = -1
Long: Positive vote count >= minimum-votes parameter AND weighted vote sum > 0
Short: Negative vote count >= minimum-votes parameter AND weighted vote sum < 0
Long: Positive vote count >= minimum-votes parameter AND weighted vote sum > 0 AND prior confirmed consensus was not long
Short: Negative vote count >= minimum-votes parameter AND weighted vote sum < 0 AND prior confirmed consensus was not short