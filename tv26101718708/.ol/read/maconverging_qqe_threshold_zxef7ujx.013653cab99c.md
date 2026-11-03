Calculation: Smoothed RSI = selected moving average of RSI(close, RSI lookback), using the selected smoothing type and smoothing lookback
Calculation: Adaptive average = recursively updated close average; its alpha resets to 2/(lookback+1) when close crosses the prior average, increases by 1/increment when close is above the average and the rolling high rises or close is below the average and the rolling low falls, and otherwise holds; update the average using the prior alpha
Calculation: Fast converging average = at a close cross of the adaptive average, average close with its prior value; otherwise, when close is above the adaptive average, max(close, prior fast average) + (close - prior fast average)/fast lookback; when below, min(close, prior fast average) + (close - prior fast average)/fast lookback
Calculation: ATR stop distance = selected moving average of true range over the ATR lookback multiplied by the ATR multiplier
Calculation: Long stop = low minus ATR stop distance on the long entry bar, held at that value while the position is open
Calculation: Short stop = high plus ATR stop distance on the short entry bar, held at that value while the position is open
Long: Smoothed RSI > 50 + threshold OR fast converging average > adaptive average OR (Smoothed RSI > 50 + threshold AND prior Smoothed RSI <= 50 + threshold AND fast converging average > adaptive average)
Short: RSI(close, RSI lookback) < 50 - threshold OR fast converging average <= adaptive average OR (Smoothed RSI < 50 - threshold AND prior Smoothed RSI >= 50 - threshold AND fast converging average < adaptive average)
Exit: long, Smoothed RSI < 50 - threshold OR low <= Long stop
Exit: short, Smoothed RSI > 50 + threshold OR high >= Short stop