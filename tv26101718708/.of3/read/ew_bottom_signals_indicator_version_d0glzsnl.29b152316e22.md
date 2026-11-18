Calculation: body size = abs(close - open)
Calculation: wick size = high - low - body size
Calculation: short-term moving average = SMA(close, shorter lookback)
Calculation: long-term moving average = SMA(close, longer lookback)
Long: Wave C is active AND close < long-term moving average AND open > close AND wick size > body size AND volume > SMA(volume, volume lookback) * volume multiplier
Long: (Wave C is active AND close < long-term moving average AND open > close AND wick size > body size AND volume > SMA(volume, volume lookback) * volume multiplier) on the previous bar AND crossover(close, short-term moving average)
Long: (Wave C is active AND close < long-term moving average AND open > close AND wick size > body size AND volume > SMA(volume, volume lookback) * volume multiplier) two bars ago AND crossover(close, short-term moving average) on the previous bar AND crossover(short-term moving average, long-term moving average)
Exit: long, crossunder(short-term moving average, long-term moving average)