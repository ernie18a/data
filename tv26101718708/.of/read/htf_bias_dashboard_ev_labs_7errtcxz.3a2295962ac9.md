Calculation: Timeframe values = for each of six configurable timeframes, calculate close, EMA of close, and RSI of close in that timeframe; on historical chart bars use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar; on a live chart bar use the forming higher-timeframe bar or the latest available lower-timeframe bar. For the chart timeframe, use the current bar.
Calculation: Bullish count = number of timeframes whose close is above their short-lookback EMA.
Calculation: Bearish count = number of timeframes whose close is below their short-lookback EMA.
Long: Timeframe close > short-lookback EMA.
Short: Timeframe close < short-lookback EMA.
Long: Timeframe close > short-lookback EMA AND short-lookback EMA > medium-lookback EMA AND medium-lookback EMA > long-lookback EMA.
Short: Timeframe close < short-lookback EMA AND short-lookback EMA < medium-lookback EMA AND medium-lookback EMA < long-lookback EMA.
Long: Timeframe RSI < lower RSI threshold.
Short: Timeframe RSI > upper RSI threshold.
Long: Bullish count >= overall-bias majority threshold.
Short: Bearish count >= overall-bias majority threshold.
Long: Bullish count >= strong-bias threshold, which is higher than the overall-bias majority threshold.
Short: Bearish count >= strong-bias threshold, which is higher than the overall-bias majority threshold.
Long: Bullish count = number of timeframes.
Short: Bearish count = number of timeframes.