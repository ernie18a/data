Calculation: TFState(tf) = on timeframe tf, using the bar still forming (current close, and fast and slow EMAs of close computed on tf bars): +1 if close > fast EMA AND fast EMA > slow EMA; -1 if close < fast EMA AND fast EMA < slow EMA; otherwise 0. The fast EMA has a shorter period than the slow EMA.
Calculation: Score = sum of TFState(tf) over a fixed set of timeframes spanning from lower than the chart timeframe to higher than the chart timeframe.
Long: Score >= a positive threshold
Short: Score <= the negative of that threshold