Calculation: Weighted price = (high + low + 2 × close) / 4
Calculation: Median price = (high + low) / 2
Calculation: Short-lookback EMA = exponential moving average of close on each of the five configured higher or chart timeframes, using its still-forming bar; its lookback is shorter than the long-lookback EMA.
Calculation: Long-lookback EMA = exponential moving average of close on each of the five configured higher or chart timeframes, using its still-forming bar; its lookback is longer than the short-lookback EMA.
Calculation: Short-lookback RSI = RSI of weighted price on each of the five configured higher or chart timeframes, using its still-forming bar; its lookback is shorter than the long-lookback RSI.
Calculation: Long-lookback RSI = RSI of median price on each of the five configured higher or chart timeframes, using its still-forming bar; its lookback is longer than the short-lookback RSI.
Long: For any configured timeframe, short-lookback EMA > long-lookback EMA AND short-lookback RSI >= long-lookback RSI, OR short-lookback EMA >= long-lookback EMA AND short-lookback RSI > long-lookback RSI
Short: For any configured timeframe, short-lookback EMA < long-lookback EMA AND short-lookback RSI <= long-lookback RSI, OR short-lookback EMA <= long-lookback EMA AND short-lookback RSI < long-lookback RSI