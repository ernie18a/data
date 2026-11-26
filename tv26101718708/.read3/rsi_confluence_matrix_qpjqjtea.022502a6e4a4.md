Calculation: RSI = RSI(close, RSI lookback, T7, current bar), calculated on T7 bars and sampled on chart bars using the current, still-forming T7 bar
Calculation: oversold-cross count = number of RSI crosses below the oversold level since the most recent RSI cross above the overbought level or long entry signal; reset on either event
Calculation: overbought-cross count = number of RSI crosses above the overbought level since the most recent RSI cross below the oversold level or short entry signal; reset on either event
Calculation: above-EMA timeframe count = count over T1–T6 for which close(T, current bar) > EMA(close, EMA lookback, T, current bar), calculated on T bars and sampled on chart bars using each current, still-forming T bar
Calculation: below-EMA timeframe count = count over T1–T6 for which close(T, current bar) <= EMA(close, EMA lookback, T, current bar), calculated on T bars and sampled on chart bars using each current, still-forming T bar
Long: RSI crosses above the mid RSI level
Short: RSI crosses below the mid RSI level
Long: above-EMA timeframe count > below-EMA timeframe count
Short: below-EMA timeframe count > above-EMA timeframe count
Long: pivot low(low, pivot-left lookback, pivot-right lookback) and pivot low(RSI, pivot-left lookback, pivot-right lookback) are confirmed AND low[pivot-right lookback] < low[pivot-right lookback + pivot-left lookback] AND RSI[pivot-right lookback] > RSI[pivot-right lookback + pivot-left lookback]
Short: pivot high(high, pivot-left lookback, pivot-right lookback) and pivot high(RSI, pivot-left lookback, pivot-right lookback) are confirmed AND high[pivot-right lookback] > high[pivot-right lookback + pivot-left lookback] AND RSI[pivot-right lookback] < RSI[pivot-right lookback + pivot-left lookback]
Long: oversold-cross count >= repeated-extreme count AND RSI crosses above the mid RSI level AND above-EMA timeframe count >= minimum aligned-timeframe count
Short: overbought-cross count >= repeated-extreme count AND RSI crosses below the mid RSI level AND below-EMA timeframe count >= minimum aligned-timeframe count