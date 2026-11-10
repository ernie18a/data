Calculation: Bull score = count of these true conditions: shortest EMA of close > middle EMA of close AND middle EMA > longer EMA; close > longest EMA of close; RSI > bullish lower threshold AND RSI < overbought threshold; MACD line > signal line AND MACD line crossed above signal line within a specified number of bars including the current bar; close > session VWAP of typical price; close > Bollinger middle band AND close < upper band; Supertrend direction is bullish; stochastic %K > its SMA %D AND %K < overbought threshold; volume > a multiplier of its SMA.
Calculation: Bear score = count of these true conditions: shortest EMA of close < middle EMA of close AND middle EMA < longer EMA; close < longest EMA of close; RSI < bearish upper threshold AND RSI > oversold threshold; MACD line < signal line AND MACD line crossed below signal line within the same specified number of bars including the current bar; close < session VWAP of typical price; close < Bollinger middle band AND close > lower band; Supertrend direction is bearish; stochastic %K < its SMA %D AND %K > oversold threshold; volume > the same multiplier of its SMA.
Long: Bull score >= minimum score AND Bull score > Bear score AND (previous Bull score < minimum score OR previous Bull score <= previous Bear score).
Short: Bear score >= minimum score AND Bear score > Bull score AND (previous Bear score < minimum score OR previous Bear score <= previous Bull score).
Long: shortest EMA of close > middle EMA of close AND middle EMA of close > longer EMA of close.
Short: shortest EMA of close <= middle EMA of close OR middle EMA of close <= longer EMA of close.
Long: close > longest EMA of close.
Short: close <= longest EMA of close.
Long: RSI > bullish lower threshold AND RSI < overbought threshold.
Short: RSI <= bullish lower threshold OR RSI >= overbought threshold.
Long: close > session VWAP of typical price.
Short: close <= session VWAP of typical price.
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Long: stochastic %K > its SMA %D AND %K < overbought threshold.
Short: stochastic %K <= its SMA %D OR %K >= overbought threshold.
Long: close > Bollinger middle band AND close < upper band.
Short: close <= Bollinger middle band OR close >= upper band.