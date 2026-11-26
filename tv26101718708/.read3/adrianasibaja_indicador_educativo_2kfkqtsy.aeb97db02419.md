Calculation: Long trend points = (close > EMA(close, long lookback) ? 1 : 0) + (EMA(close, medium lookback) > EMA(close, long lookback) ? 1 : 0) + (EMA(close, short lookback) > EMA(close, medium lookback) ? 1 : 0) + (+DI(ADX lookback, ADX smoothing) > -DI(ADX lookback, ADX smoothing) ? 1 : 0)
Calculation: Short trend points = (close < EMA(close, long lookback) ? 1 : 0) + (EMA(close, medium lookback) < EMA(close, long lookback) ? 1 : 0) + (EMA(close, short lookback) < EMA(close, medium lookback) ? 1 : 0) + (-DI(ADX lookback, ADX smoothing) > +DI(ADX lookback, ADX smoothing) ? 1 : 0)
Calculation: Latest confirmed swing high = most recent confirmed PivotHigh(high, swing lookback, swing lookback)
Calculation: Latest confirmed swing low = most recent confirmed PivotLow(low, swing lookback, swing lookback)
Calculation: Previous confirmed pivot high = confirmed PivotHigh(high, swing lookback, swing lookback) preceding the current pivot high
Calculation: Previous confirmed pivot low = confirmed PivotLow(low, swing lookback, swing lookback) preceding the current pivot low
Long: Long trend points >= trend threshold AND ADX(ADX lookback, ADX smoothing) > ADX threshold AND RSI(close, RSI lookback) > lower RSI threshold AND RSI(close, RSI lookback) < upper RSI threshold AND, on chart bars using the last completed T1 bar, close(T1) > EMA(close(T1), medium lookback) AND close(T1) > EMA(close(T1), long lookback) AND chart bars since the previous long quality signal > cooldown
Short: Short trend points >= trend threshold AND ADX(ADX lookback, ADX smoothing) > ADX threshold AND RSI(close, RSI lookback) > lower RSI threshold AND RSI(close, RSI lookback) < upper RSI threshold AND, on chart bars using the last completed T1 bar, close(T1) < EMA(close(T1), medium lookback) AND close(T1) < EMA(close(T1), long lookback) AND chart bars since the previous short quality signal > cooldown
Long: current confirmed PivotLow(low, swing lookback, swing lookback) < previous paired confirmed price pivot low AND current confirmed PivotLow(RSI(close, RSI lookback), swing lookback, swing lookback) > previous paired confirmed RSI pivot low AND chart bars since the previous bullish divergence > cooldown
Short: current confirmed PivotHigh(high, swing lookback, swing lookback) > previous paired confirmed price pivot high AND current confirmed PivotHigh(RSI(close, RSI lookback), swing lookback, swing lookback) < previous paired confirmed RSI pivot high AND chart bars since the previous bearish divergence > cooldown
Long: crosses above latest confirmed swing high
Short: crosses below latest confirmed swing low
Long: PivotHigh(high, swing lookback, swing lookback) > previous confirmed pivot high OR PivotLow(low, swing lookback, swing lookback) > previous confirmed pivot low
Short: PivotHigh(high, swing lookback, swing lookback) < previous confirmed pivot high OR PivotLow(low, swing lookback, swing lookback) <= previous confirmed pivot low
Long: PivotLow(low, swing lookback, swing lookback) is present AND close[swing lookback] < open[swing lookback]
Short: PivotHigh(high, swing lookback, swing lookback) is present AND close[swing lookback] > open[swing lookback]
Long: low > high[2]
Short: high < low[2]