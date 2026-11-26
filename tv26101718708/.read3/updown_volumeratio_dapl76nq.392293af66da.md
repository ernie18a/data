Calculation: log up/down volume ratio = log(sum(volume when close > close[1], lookback) / sum(volume when close < close[1], lookback)), undefined when the denominator is zero
Long: log up/down volume ratio crosses above EMA(log up/down volume ratio, EMA lookback)
Short: log up/down volume ratio crosses below EMA(log up/down volume ratio, EMA lookback)