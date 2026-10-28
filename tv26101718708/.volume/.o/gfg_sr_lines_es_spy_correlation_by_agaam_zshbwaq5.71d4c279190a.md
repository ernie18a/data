Calculation: Stochastic %K = smoothed stochastic of high, low, and close; %D = smoothed %K
Calculation: MACD histogram = MACD line minus signal line
Calculation: Bullish trend = close above EMA and EMA above its previous value
Calculation: Bearish trend = close below EMA and EMA below its previous value
Calculation: Near EMA = absolute distance from close to EMA is at most 0.8 ATR
Calculation: Long stop = at entry, the lower of the lowest low over the swing lookback plus the entry bar and the entry bar low, minus an ATR buffer
Calculation: Short stop = at entry, the higher of the highest high over the swing lookback plus the entry bar and the entry bar high, plus an ATR buffer
Long: bullish trend AND near EMA AND both %K and %D are within the bullish pullback zone AND %K crosses above %D AND MACD histogram rises AND close > open AND ADX >= minimum AND volume > its moving average × volume multiplier AND ES and SPY are each above their EMA and their EMA is rising (and, if correlation momentum is enabled, each has %K >= %D)
Short: bearish trend AND near EMA AND either %K or %D is within the bearish pullback zone AND %K crosses below %D AND MACD histogram falls AND close < open AND ADX >= minimum AND volume > its moving average × volume multiplier AND ES and SPY are each below their EMA and their EMA is falling (and, if correlation momentum is enabled, each has %K <= %D)
Exit: long, %K >= 80 AND %K crosses below %D OR low <= long stop
Exit: short, %K <= 20 AND %K crosses above %D OR high >= short stop