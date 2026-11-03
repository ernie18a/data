Calculation: Pullback condition = At least the minimum number of bars with close < open among the preceding lookback bars.
Calculation: Red-streak count = Number of consecutive bars immediately preceding the current bar with close < open, stopping at the first bar that does not.
Calculation: First green after pullback = Red-streak count >= the minimum red-bar count AND current close > open.
Calculation: Bullish EMA crossover = The shorter-lookback EMA crosses from <= to > the longer-lookback EMA.
Calculation: Bullish MACD crossover = The MACD line crosses from <= to > its signal line.
Calculation: MACD histogram turns positive = Current MACD histogram > 0 AND previous MACD histogram <= 0.
Calculation: Long filters pass = (VWAP filter disabled OR close > VWAP) AND (trend-EMA filter disabled OR close > trend EMA).
Calculation: Strong-long condition = Long filters pass AND close >= open AND ((Bullish EMA crossover AND (MACD line > signal line OR Bullish MACD crossover) AND Pullback condition) OR (Bullish MACD crossover AND shorter-lookback EMA > longer-lookback EMA AND First green after pullback AND Pullback condition) OR (Bullish EMA crossover AND Bullish MACD crossover)).
Long: Strong-long condition
Calculation: Medium-long condition = Long filters pass AND NOT Strong-long condition AND close >= open AND First green after pullback AND (MACD line > signal line OR MACD histogram turns positive) AND Pullback condition.
Long: Medium-long condition
Calculation: Early-long condition = Long filters pass AND NOT Strong-long condition AND NOT Medium-long condition AND MACD histogram turns positive AND Pullback condition.
Long: Early-long condition