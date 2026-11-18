Long: RSI(close, RSI lookback) > long-entry threshold AND MovingAverage(RSI(close, RSI lookback), MA lookback, MA type) > MovingAverage(RSI(close, RSI lookback), MA lookback, MA type)[1]
Short: RSI(close, RSI lookback) < short-entry threshold AND MovingAverage(RSI(close, RSI lookback), MA lookback, MA type) < MovingAverage(RSI(close, RSI lookback), MA lookback, MA type)[1]
Exit: long, RSI(close, RSI lookback) < long-exit threshold
Exit: short, RSI(close, RSI lookback) > short-exit threshold
Exit: long, high >= high[1] * (1 + first long target parameter)
Exit: long, high >= high[1] * (1 + second long target parameter)
Exit: long, low <= low[1] * (1 - long stop parameter)
Exit: short, low <= low[1] * (1 - first short target parameter)
Exit: short, low <= low[1] * (1 - second short target parameter)
Exit: short, high >= high[1] * (1 + short stop parameter)