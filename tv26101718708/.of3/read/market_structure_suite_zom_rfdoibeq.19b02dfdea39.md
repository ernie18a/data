Calculation: Structural bias = 1 after a confirmed PivotHigh(high, structural lookback, structural lookback) exceeds the preceding confirmed pivot high; -1 after a confirmed PivotLow(low, structural lookback, structural lookback) falls below the preceding confirmed pivot low; otherwise retain the previous value, initially 0.
Calculation: Signal availability = true after any confirmed structural pivot high or low and false after a long or short retracement signal, initially false.
Calculation: T2 bias = 1 when, on chart bars, the still-forming T2 high and low values each exceed their preceding chart-bar sampled values; -1 when each is below; otherwise retain the previous value, initially 0.
Calculation: T3 bias = 1 when, on chart bars, the still-forming T3 high and low values each exceed their preceding chart-bar sampled values; -1 when each is below; otherwise retain the previous value, initially 0.
Long: Structural bias = 1
Short: Structural bias = -1
Long: A confirmed structural PivotHigh(high, structural lookback, structural lookback) exceeds the preceding confirmed pivot high
Short: A confirmed structural PivotHigh(high, structural lookback, structural lookback) is less than or equal to the preceding confirmed pivot high
Long: A confirmed structural PivotLow(low, structural lookback, structural lookback) is greater than or equal to the preceding confirmed pivot low
Short: A confirmed structural PivotLow(low, structural lookback, structural lookback) falls below the preceding confirmed pivot low
Long: Signal availability AND a confirmed structural pivot high and low exist AND Structural bias = 1 AND low < latest confirmed pivot high - abs(latest confirmed pivot high - latest confirmed pivot low) * retracement fraction AND close > open AND close > high[1]
Short: Signal availability AND a confirmed structural pivot high and low exist AND Structural bias = -1 AND high > latest confirmed pivot low + abs(latest confirmed pivot high - latest confirmed pivot low) * retracement fraction AND close < open AND close < low[1]
Long: A confirmed PivotLow(RSI(close, RSI length), RSI pivot span, RSI pivot span) AND low[RSI pivot span] < the low at the preceding confirmed RSI pivot low AND RSI(close, RSI length)[RSI pivot span] > the RSI value at the preceding confirmed RSI pivot low
Short: A confirmed PivotHigh(RSI(close, RSI length), RSI pivot span, RSI pivot span) AND high[RSI pivot span] > the high at the preceding confirmed RSI pivot high AND RSI(close, RSI length)[RSI pivot span] < the RSI value at the preceding confirmed RSI pivot high
Long: On chart bars, low < low(T1, last completed bar) AND close > low(T1, last completed bar)
Short: On chart bars, high > high(T1, last completed bar) AND close < high(T1, last completed bar)
Long: T2 bias = 1
Short: T2 bias != 1
Long: T3 bias = 1
Short: T3 bias != 1