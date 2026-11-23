Calculation: bullish white-candle breakout = high > max(high of detected white candle, high of preceding bar, high of following bar) AND a white candle has been detected AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND no signal has already been given for that white candle AND EMA(close, shorter lookback) does not cross above EMA(close, longer lookback) on this bar
Calculation: bearish white-candle breakout = low < min(low of detected white candle, low of preceding bar, low of following bar) AND a white candle has been detected AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND no signal has already been given for that white candle AND EMA(close, shorter lookback) does not cross below EMA(close, longer lookback) on this bar
Long: bullish white-candle breakout
Short: bearish white-candle breakout
Option: buy call, bullish white-candle breakout
Option: buy put, bearish white-candle breakout
Calculation: RSI pivot-low confirmation = pivotlow(RSI(close, divergence RSI lookback), left pivot lookback, right pivot lookback) is not na
Calculation: RSI pivot-high confirmation = pivothigh(RSI(close, divergence RSI lookback), left pivot lookback, right pivot lookback) is not na
Calculation: previous pivot-low price = valuewhen(RSI pivot-low confirmation, low[right pivot lookback], previous occurrence)
Calculation: previous pivot-low RSI = valuewhen(RSI pivot-low confirmation, RSI(close, divergence RSI lookback)[right pivot lookback], previous occurrence)
Calculation: previous pivot-high price = valuewhen(RSI pivot-high confirmation, high[right pivot lookback], previous occurrence)
Calculation: previous pivot-high RSI = valuewhen(RSI pivot-high confirmation, RSI(close, divergence RSI lookback)[right pivot lookback], previous occurrence)
Long: RSI pivot-low confirmation AND barssince((RSI pivot-low confirmation)[1]) is between the lower and upper pivot-range parameters, inclusive AND ((low[right pivot lookback] < previous pivot-low price AND RSI(close, divergence RSI lookback)[right pivot lookback] > previous pivot-low RSI) OR (low[right pivot lookback] > previous pivot-low price AND RSI(close, divergence RSI lookback)[right pivot lookback] < previous pivot-low RSI))
Short: RSI pivot-high confirmation AND barssince((RSI pivot-high confirmation)[1]) is between the lower and upper pivot-range parameters, inclusive AND ((high[right pivot lookback] > previous pivot-high price AND RSI(close, divergence RSI lookback)[right pivot lookback] < previous pivot-high RSI) OR (high[right pivot lookback] < previous pivot-high price AND RSI(close, divergence RSI lookback)[right pivot lookback] > previous pivot-high RSI))
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Long: RSI(close, reversal RSI lookback) crosses above the lower RSI threshold AND open < close
Short: RSI(close, reversal RSI lookback) crosses below the upper RSI threshold