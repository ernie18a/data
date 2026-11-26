Calculation: Trend bullish = HMA(close, fast length) > HMA(close, fast length)[1] AND close > WMA(close, slow length)
Calculation: Trend bearish = HMA(close, fast length) < HMA(close, fast length)[1] AND close < WMA(close, slow length)
Calculation: Momentum bullish = RSI(close, RSI length) > upper RSI threshold AND MACD histogram(close, shorter MACD length, longer MACD length, MACD signal length) > 0 AND MACD histogram(close, shorter MACD length, longer MACD length, MACD signal length) > MACD histogram(close, shorter MACD length, longer MACD length, MACD signal length)[1]
Calculation: Momentum bearish = RSI(close, RSI length) < lower RSI threshold AND MACD histogram(close, shorter MACD length, longer MACD length, MACD signal length) < 0 AND MACD histogram(close, shorter MACD length, longer MACD length, MACD signal length) < MACD histogram(close, shorter MACD length, longer MACD length, MACD signal length)[1]
Calculation: Volume confirmed = volume > SMA(volume, volume length) * volume multiplier AND SMA(volume, shorter volume length) > SMA(volume, longer volume length)
Calculation: Volatility regime OK = low percentile <= PercentRank(ATR(ATR length), percentile lookback) <= high percentile
Calculation: Bull confluence = count of true among Trend bullish, Momentum bullish, Volume confirmed, Volatility regime OK
Calculation: Bear confluence = count of true among Trend bearish, Momentum bearish, Volume confirmed, Volatility regime OK
Long: Bull confluence >= minimum confluence
Long: Bull confluence >= minimum confluence AND Bull confluence[1] < minimum confluence AND position side is not long AND bars since last entry >= cooldown
Short: Bear confluence >= minimum confluence
Short: Bear confluence >= minimum confluence AND Bear confluence[1] < minimum confluence AND position side is not short AND bars since last entry >= cooldown