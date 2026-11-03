Calculation: Higher-timeframe bias = for a specified higher timeframe, +1 if the current bar's high > the previous bar's high AND its low >= the previous bar's low; otherwise -1 if the current high <= the previous high AND the current low < the previous low; otherwise +1 if the current close > the midpoint of the previous high and low, else -1. Use the bar still forming and the last completed bar; the source uses lookahead, so historical current-bar values are the completed higher-timeframe bar's final values.
Calculation: Sweep bias = using the last completed bar and the bar before it on the shorter higher timeframe, +1 if the last completed close > the earlier high; else -1 if the last completed close < the earlier low; else, if the last completed high >= the earlier high AND its low <= the earlier low, -1 if high - close < close - low, +1 if close - low < high - close, otherwise 0; else -1 if high >= the earlier high AND low > the earlier low; else +1 if low <= the earlier low AND high < the earlier high; else 0.
Calculation: Final bias = the longer higher-timeframe bias if nonzero; otherwise the shorter higher-timeframe bias if nonzero; otherwise sweep bias.
Long: Longer higher-timeframe bias = +1.
Short: Longer higher-timeframe bias = -1.
Long: Shorter higher-timeframe bias = +1.
Short: Shorter higher-timeframe bias = -1.
Long: Sweep bias = +1.
Short: Sweep bias = -1.
Long: Final bias = +1.
Short: Final bias = -1.
Long: The still-forming shorter higher-timeframe close <= the midpoint of its high and low. Historical values use the completed higher-timeframe bar's final values via lookahead.
Short: The still-forming shorter higher-timeframe close > the midpoint of its high and low. Historical values use the completed higher-timeframe bar's final values via lookahead.
Long: Current bar time is within a configured session AND final bias = +1 AND close > open AND absolute body size > a multiple of the simple moving average of absolute body size, including the current bar AND low > the high two chart bars ago.
Short: Current bar time is within a configured session AND final bias = -1 AND close < open AND absolute body size > a multiple of the simple moving average of absolute body size, including the current bar AND high < the low two chart bars ago.