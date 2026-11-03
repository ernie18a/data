Calculation: Drawdown from rolling high = (rolling highest high − close) / rolling highest high × 100
Calculation: Rally from rolling low = (close − rolling lowest low) / rolling lowest low × 100
Calculation: ATR ratio = shorter-lookback ATR / longer-lookback ATR
Calculation: Volume ratio = shorter-lookback average volume / longer-lookback average volume
Calculation: Recent close crossover = close crossed above its moving average within the confirmation window, including the current bar
Calculation: Recent volume spike = volume was at least the longer-lookback average volume × spike multiplier within the confirmation window, including the current bar
Calculation: Recent RSI crossover = RSI crossed above its threshold within the larger of the confirmation window plus two bars or five bars, including the current bar
Long: (Drawdown from rolling high ≥ minimum drawdown AND Rally from rolling low ≤ maximum rally AND (ATR ratio ≤ volatility threshold OR Volume ratio ≤ volume threshold)) OR (Drawdown from rolling high ≥ minimum drawdown AND Rally from rolling low ≤ maximum rally AND (ATR ratio ≤ volatility threshold OR Volume ratio ≤ volume threshold) AND Recent close crossover AND Recent volume spike AND close > open AND Recent RSI crossover)