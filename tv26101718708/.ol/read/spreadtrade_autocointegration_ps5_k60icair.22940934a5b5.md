Calculation: ratio = ln(close / close of the last completed bar on the selected timeframe)
Calculation: z-score = (short-term selected moving average of ratio - long-term selected moving average of ratio) / standard deviation of the long-term moving average over the average of the short- and long-term lookbacks
Long: z-score < -threshold AND prior signal is not long
Short: z-score > threshold AND prior signal is not short
Exit: Long or Short, -threshold <= z-score <= threshold OR consecutive bars with an active long or short signal > tick threshold