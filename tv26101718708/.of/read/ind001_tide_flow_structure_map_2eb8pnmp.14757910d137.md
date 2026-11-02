Calculation: Upper structure = EMA of the rolling highest high.
Calculation: Lower structure = EMA of the rolling lowest low, using the same lookback and smoothing lengths as the upper structure.
Calculation: Long trend = close above the long-term close EMA AND the short-term close EMA above the long-term close EMA AND the long-term close EMA above its previous value.
Calculation: Main gates = long trend AND ADX at or above its threshold AND ATR divided by close at or above its threshold AND, if the higher-timeframe filter is enabled, the higher-timeframe close above its EMA, using the last completed higher-timeframe bar.
Calculation: Recent bearish phase = the number of chart bars with close below the long-term close EMA within a rolling lookback is at or above its threshold.
Calculation: ATR trail = on the first long-setup bar, close minus a multiple of ATR; on each subsequent bar while the setup remains active, the greater of its previous value and current close minus the same multiple of ATR. Reset after exit.
Long: Long trend.
Long: Close above the short-term close EMA AND close below upper structure.
Long: Main gates.
Long: Main gates AND close crosses above upper structure.
Long: Main gates AND close above the short-term close EMA AND close above the long-term close EMA.
Long: Recent bearish phase AND close above the long-term close EMA AND, if the recent-cross filter is enabled, the number of bars since close crossed above the long-term close EMA is at or below its threshold.
Long: Main gates AND RSI at or below its upper threshold AND percentage change of the short-term close EMA from the previous bar at or above the negative slope threshold AND (close above previous bar's upper structure OR low at or below the short-term close EMA AND close above it OR close crosses above the short-term close EMA) AND the number of bars since the previous long setup is greater than the cooldown length, or no previous long setup exists.
Exit: Long, the long setup is active AND close has been below the greater of the ATR trail and lower structure for at least the required number of consecutive bars.