Calculation: bull trend = EMA(close, shorter lookback) > EMA(close, longer lookback)
Calculation: bull regime = close > EMA(close, regime lookback) AND (strict regime is off OR rising(EMA(close, regime lookback), regime slope lookback))
Calculation: bear regime = close < EMA(close, regime lookback) AND (strict regime is off OR falling(EMA(close, regime lookback), regime slope lookback))
Calculation: EPS acceleration = ROC(close, EPS lookback) - ROC(close, longer EPS lookback)
Calculation: relative strength = (close / close[RS lookback]) / (benchmark close / benchmark close[RS lookback])
Calculation: volume surge = volume >= SMA(volume, volume lookback) * volume multiplier
Calculation: MACD histogram = MACD(close, MACD fast length, MACD slow length, MACD signal length) histogram
Calculation: MACD bull = MACD histogram > 0 AND MACD histogram > MACD histogram[1]
Calculation: stochastic %K = SMA(stochastic(close, high, low, %K length), %K smoothing)
Calculation: stochastic bull = stochastic %K > SMA(stochastic %K, %D length) AND stochastic %K < stochastic upper level
Calculation: recent up-cross = EMA(close, shorter lookback) crosses above EMA(close, longer lookback) on some bar within the last long cross lookback bars, including the current bar
Calculation: recent down-cross = EMA(close, shorter lookback) crosses below EMA(close, longer lookback) on some bar within the last short cross lookback bars, including the current bar
Calculation: bars since last long entry = bars since the last bar on which the long entry condition held, infinite if none
Calculation: bars since last short entry = bars since the last bar on which the short entry condition held, infinite if none
Calculation: total score = number of true conditions among: bull trend; close > EMA(close, longest lookback); EMA(EPS acceleration, EPS smoothing lookback) > EPS threshold; relative strength >= RS threshold; volume surge; bull regime; RSI(close, RSI lookback) > RSI midline AND RSI(close, RSI lookback) < RSI overbought level; stochastic bull; MACD bull; close > VWAP(typical price); ADX(high, low, close, ADX lookback) >= ADX threshold
Long: total score >= long score minimum AND bull trend AND bull regime AND recent up-cross AND bars since last long entry > cooldown length
Short: total score <= short score maximum AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND bear regime AND recent down-cross AND bars since last short entry > cooldown length
Long: stochastic bull
Long: MACD bull
Long: bull regime
Long: total score >= high score level AND bull regime
Long: volume surge AND MACD bull AND bull trend
Short: bear regime