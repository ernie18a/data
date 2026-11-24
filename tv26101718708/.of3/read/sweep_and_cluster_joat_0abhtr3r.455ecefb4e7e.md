Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: bar range = high - low
Calculation: body = abs(close - open)
Calculation: bar direction = +1 if close >= open, else -1
Calculation: reference high = price of the newest PivotHigh(pivot lookback, pivot lookback) event that occurred at least pivot min age bars before this bar, among the newest pivot scan depth events of PivotHigh(pivot lookback, pivot lookback) or PivotLow(pivot lookback, pivot lookback) combined
Calculation: reference low = price of the newest PivotLow(pivot lookback, pivot lookback) event that occurred at least pivot min age bars before this bar, among the newest pivot scan depth events of PivotHigh(pivot lookback, pivot lookback) or PivotLow(pivot lookback, pivot lookback) combined
Calculation: bars since last bull sweep = bars back to the most recent bar before this bar where the bull sweep condition held (infinite if none)
Calculation: bars since last bear sweep = bars back to the most recent bar before this bar where the bear sweep condition held (infinite if none)
Calculation: bull sweep pending = bars since last bull sweep <= cluster window AND no bull SAC confirmed after the last bull sweep and before this bar
Calculation: bear sweep pending = bars since last bear sweep <= cluster window AND no bear SAC confirmed after the last bear sweep and before this bar
Calculation: last SAC direction = +1 if the most recent SAC confirmed on or before this bar is bull, -1 if it is bear, 0 if none
Long: low < reference low AND close > reference low AND lower wick >= ATR(wick ATR lookback) * wick ATR multiplier AND lower wick / bar range >= wick ratio AND bars since last bull sweep > sweep cooldown AND (overlap allowed OR NOT bull sweep pending)
Short: high > reference high AND close < reference high AND upper wick >= ATR(wick ATR lookback) * wick ATR multiplier AND upper wick / bar range >= wick ratio AND bars since last bear sweep > sweep cooldown AND (overlap allowed OR NOT bear sweep pending)
Long: bull sweep pending AND COUNT(bar direction = +1, bars since last bull sweep) >= min qualifying bars AND SUM(body, bars since last bull sweep, bar direction = +1) / SUM(bar range, bars since last bull sweep, bar direction = +1) >= min body ratio AND SMA(volume, bars since last bull sweep) / SMA(volume, volume average lookback)[bars since last bull sweep] >= min volume multiplier
Short: bear sweep pending AND COUNT(bar direction = -1, bars since last bear sweep) >= min qualifying bars AND SUM(body, bars since last bear sweep, bar direction = -1) / SUM(bar range, bars since last bear sweep, bar direction = -1) >= min body ratio AND SMA(volume, bars since last bear sweep) / SMA(volume, volume average lookback)[bars since last bear sweep] >= min volume multiplier
Long: last SAC direction = +1
Short: last SAC direction = -1