Calculation: TrendReading = choppy if ADX(ADX lookback) < ADX threshold AND NOT (ADX(ADX lookback) - ADX(ADX lookback)[climb lookback] >= climb threshold), else bullish if MA(close, shorter lookback, average type) > MA(close, middle lookback, average type) AND MA(close, middle lookback, average type) > MA(close, longer lookback, average type) AND close > MA(close, longer lookback, average type), else bearish if MA(close, shorter lookback, average type) < MA(close, middle lookback, average type) AND MA(close, middle lookback, average type) < MA(close, longer lookback, average type) AND close < MA(close, longer lookback, average type), else mixed, where shorter lookback < middle lookback < longer lookback
Calculation: LastNonMixedTrend = TrendReading on the most recent earlier bar where TrendReading is not mixed
Calculation: PullbackUp = low <= MA(close, touch lookback, average type) + touch tolerance * ATR(ATR lookback) AND close > MA(close, hold lookback, average type) AND TrendReading = bullish
Calculation: PullbackDown = high >= MA(close, touch lookback, average type) - touch tolerance * ATR(ATR lookback) AND close < MA(close, hold lookback, average type) AND TrendReading = bearish
Calculation: RelativeStrengthLine = close / market index close
Long: PullbackUp AND NOT PullbackUp[1] AND bars since previous long pullback >= minimum gap
Short: PullbackDown AND NOT PullbackDown[1] AND bars since previous short pullback >= minimum gap
Long: TrendReading = bullish AND LastNonMixedTrend != bullish
Short: TrendReading = bearish AND LastNonMixedTrend != bearish
Long: TrendReading = bullish
Short: TrendReading = bearish
Long: close > MA(close, middle lookback, average type)
Short: close < MA(close, middle lookback, average type)
Long: MA(close, cloud 1 fast lookback, average type) > MA(close, cloud 1 slow lookback, average type)
Short: MA(close, cloud 1 fast lookback, average type) <= MA(close, cloud 1 slow lookback, average type)
Long: MA(close, cloud 1 fast lookback, average type) crosses above MA(close, cloud 1 slow lookback, average type)
Short: MA(close, cloud 1 fast lookback, average type) crosses below MA(close, cloud 1 slow lookback, average type)
Long: MA(close, cloud 2 fast lookback, average type) > MA(close, cloud 2 slow lookback, average type)
Short: MA(close, cloud 2 fast lookback, average type) <= MA(close, cloud 2 slow lookback, average type)
Long: MA(close, cloud 2 fast lookback, average type) crosses above MA(close, cloud 2 slow lookback, average type)
Short: MA(close, cloud 2 fast lookback, average type) crosses below MA(close, cloud 2 slow lookback, average type)
Long: MA(close, line lookback, average type) > MA(close, line lookback, average type)[slope lookback]
Short: MA(close, line lookback, average type) < MA(close, line lookback, average type)[slope lookback]
Long: RelativeStrengthLine >= highest(RelativeStrengthLine, RS lookback) AND highest(RelativeStrengthLine, RS lookback) - lowest(RelativeStrengthLine, RS lookback) > minimum RS range * lowest(RelativeStrengthLine, RS lookback) AND correlation(close / close[1], market index close / market index close[1], correlation lookback) < maximum correlation
Exit: long, high >= entry price + win distance * ATR(ATR lookback) at entry bar OR low <= entry price - loss distance * ATR(ATR lookback) at entry bar OR bars since entry > max hold bars
Exit: short, low <= entry price - win distance * ATR(ATR lookback) at entry bar OR high >= entry price + loss distance * ATR(ATR lookback) at entry bar OR bars since entry > max hold bars