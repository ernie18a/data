Calculation: Last pivot low = valuewhen(pivotlow(low, left lookback, right lookback) is not na, low[right lookback], latest occurrence)
Calculation: Last pivot high = valuewhen(pivothigh(high, left lookback, right lookback) is not na, high[right lookback], latest occurrence)
Calculation: Bullish sweep failure = low < Last pivot low AND close > Last pivot low AND open > Last pivot low AND low = lowest(low, left lookback) AND lowest(close, left lookback) ≥ Last pivot low
Calculation: Bearish sweep failure = high > Last pivot high AND close < Last pivot high AND open < Last pivot high AND high = highest(high, left lookback) AND highest(close, left lookback) ≤ Last pivot high
Long: Bullish sweep failure
Short: Bearish sweep failure
Long: Bullish sweep failure[sweep delay] AND each close from the current bar through the close confirmation lookback bars ago is above its corresponding Last pivot low AND at least the cooldown period has elapsed since the previous long delayed sweep
Short: Bearish sweep failure[sweep delay] AND each close from the current bar through the close confirmation lookback bars ago is below its corresponding Last pivot high AND at least the cooldown period has elapsed since the previous short delayed sweep
Long: On chart bars, close crosses below the high of the last completed T1 bar
Short: On chart bars, close crosses below the low of the last completed T1 bar
Long: On chart bars, close crosses below the high of the last completed T2 bar
Short: On chart bars, close crosses below the low of the last completed T2 bar