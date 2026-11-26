Calculation: RSI = RSI(source, RSI lookback, T1), evaluated on chart bars using T1 values; use the last completed T1 bar when T1 is higher than the chart timeframe and non-repainting mode is enabled, otherwise use T1 with lookahead off
Calculation: Signal line = SMA, EMA, RMA, WMA, or VWMA of RSI with the signal lookback, using the same T1 bar-selection mode as RSI; SMA is used when SMA with Bollinger Bands is selected
Calculation: Bull regime = lowest(RSI, regime lookback) >= bull floor AND highest(RSI, regime lookback) > bear ceiling
Calculation: Bear regime = highest(RSI, regime lookback) <= bear ceiling AND lowest(RSI, regime lookback) < bull floor
Calculation: RSI slope = RSI - RSI[slope lookback]
Calculation: Bull score = count of true conditions: RSI > 50, RSI > signal line, signal line > 50, RSI slope > flat slope threshold, bull regime
Long: RSI >= 50
Short: RSI < 50
Long: RSI > signal line
Short: RSI < signal line
Long: bull regime
Short: bear regime
Long: bull score >= 4
Short: bull score <= 1
Long: RSI slope > flat slope threshold
Short: RSI slope < -flat slope threshold
Long: bull regime AND RSI < signal line
Short: bear regime AND RSI > signal line
Long: RSI crosses above signal line
Short: RSI crosses below signal line
Long: RSI crosses above 50
Short: RSI crosses below 50
Exit: long, RSI crosses below overbought level
Exit: short, RSI crosses above oversold level
Long: bull regime AND previous bar was not in bull regime
Short: bear regime AND previous bar was not in bear regime
Calculation: RSI pivot low = confirmed PivotLow(RSI, left pivot lookback, right pivot lookback)
Calculation: RSI pivot high = confirmed PivotHigh(RSI, left pivot lookback, right pivot lookback)
Long: divergence enabled AND confirmed RSI pivot low AND bars since the prior confirmed RSI pivot low are within the minimum and maximum pivot-gap parameters AND low[right pivot lookback] < low at the prior RSI pivot low AND RSI[right pivot lookback] > RSI at the prior RSI pivot low
Short: divergence enabled AND confirmed RSI pivot high AND bars since the prior confirmed RSI pivot high are within the minimum and maximum pivot-gap parameters AND high[right pivot lookback] > high at the prior RSI pivot high AND RSI[right pivot lookback] < RSI at the prior RSI pivot high
Long: hidden divergence enabled AND confirmed RSI pivot low AND bars since the prior confirmed RSI pivot low are within the minimum and maximum pivot-gap parameters AND low[right pivot lookback] > low at the prior RSI pivot low AND RSI[right pivot lookback] < RSI at the prior RSI pivot low
Short: hidden divergence enabled AND confirmed RSI pivot high AND bars since the prior confirmed RSI pivot high are within the minimum and maximum pivot-gap parameters AND high[right pivot lookback] < high at the prior RSI pivot high AND RSI[right pivot lookback] > RSI at the prior RSI pivot high