Long: EMA(close, fast lookback) crosses above EMA(close, slow lookback) AND RSI(close, RSI lookback) < long RSI threshold AND EMA(close, fast lookback, T1, current bar) > EMA(close, slow lookback, T1, current bar)
Short: EMA(close, fast lookback) crosses below EMA(close, slow lookback) AND RSI(close, RSI lookback) > short RSI threshold
Exit: Long, low <= close * long stop multiplier OR high >= close * long target multiplier
Exit: Short, high >= close * short stop multiplier OR low <= close * short target multiplier