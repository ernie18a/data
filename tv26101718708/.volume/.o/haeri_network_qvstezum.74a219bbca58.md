Calculation: 20-period RSI = RSI of close using the longer RSI lookback used by the entry filters
Calculation: Long RSI average = EMA of the 20-period RSI using a longer lookback
Calculation: 2-period CCI = CCI of close using a very short lookback
Calculation: CCI average = EMA of the 2-period CCI using a longer lookback
Calculation: Adjusted CCI = the 2-period CCI, adjusted by +25 on a bearish candle with body greater than a threshold or by -25 on a bullish candle with body greater than that threshold; otherwise unchanged
Calculation: Long-term RSI = RSI of close using the longer exit lookback
Calculation: Exit %K = EMA of the stochastic of the long-term RSI using the same long-term lookback, smoothed with a shorter lookback
Calculation: Exit %D = EMA of Exit %K using the same shorter smoothing lookback
Calculation: Short-term RSI = RSI of close using a very short lookback
Calculation: Entry %K = SMA of the stochastic of the short-term RSI using a longer lookback, smoothed with a shorter lookback
Calculation: Entry %D = SMA of Entry %K using a shorter lookback
Calculation: HalfTrend direction = bullish when the latest HalfTrend up reversal is more recent than its latest down reversal; bearish when the latest down reversal is more recent
Calculation: Bullish CCI turn = 2-period CCI crosses above its EMA, the prior bar's 2-period CCI is below a negative threshold, and Adjusted CCI equals 2-period CCI
Calculation: Bearish CCI turn = 2-period CCI crosses below its EMA, the prior bar's 2-period CCI is above a positive threshold, and Adjusted CCI equals 2-period CCI
Calculation: Bullish entry CCI turn = 2-period CCI crosses above its EMA and the prior bar's 2-period CCI is below a negative threshold
Calculation: Bearish entry CCI turn = 2-period CCI crosses below its EMA and the prior bar's 2-period CCI is above a positive threshold
Long: (Bullish CCI turn AND prior-bar short-term RSI is below its lower threshold AND HalfTrend direction is bullish AND 2-period CCI crosses above its EMA) OR 20-period RSI is within a small positive margin of its EMA OR (prior-bar short-term RSI is below its lower threshold AND Bullish CCI turn)
Short: (Bearish CCI turn AND prior-bar short-term RSI is above its upper threshold AND HalfTrend direction is bearish AND 20-period RSI is within a small negative margin of its EMA) OR (prior-bar short-term RSI is above its upper threshold AND Bearish CCI turn)
Exit: Long, weak short-entry score is met AND Exit %K < Exit %D AND no long-entry condition
Exit: Short, weak long-entry score is met AND Exit %K > Exit %D AND no short-entry condition
Exit: Long, close crosses below the stop level calculated from entry price and a configurable loss percentage
Exit: Short, close crosses above the stop level calculated from entry price and a configurable loss percentage