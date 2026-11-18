Calculation: latest confirmed pivot high = most recent non-na PivotHigh(high, pivot lookback, pivot lookback)
Calculation: latest confirmed pivot low = most recent non-na PivotLow(low, pivot lookback, pivot lookback)
Long: on chart bars, datetime is within the configured session AND entry signals since the start of the current, still-forming T1 bar < entry-count limit AND P&L since the start of the current T1 period > -loss limit AND low < latest confirmed pivot low AND close > latest confirmed pivot low AND close > EMA(close, lookback)
Short: on chart bars, datetime is within the configured session AND entry signals since the start of the current, still-forming T1 bar < entry-count limit AND P&L since the start of the current T1 period > -loss limit AND high > latest confirmed pivot high AND close < latest confirmed pivot high AND close < EMA(close, lookback)
Exit: long, low <= latest confirmed pivot low at entry signal
Exit: long, high >= close at entry signal + (close at entry signal - latest confirmed pivot low at entry signal) * lower target multiple
Exit: long, high >= close at entry signal + (close at entry signal - latest confirmed pivot low at entry signal) * higher target multiple
Exit: short, high >= latest confirmed pivot high at entry signal
Exit: short, low <= close at entry signal - (latest confirmed pivot high at entry signal - close at entry signal) * lower target multiple
Exit: short, low <= close at entry signal - (latest confirmed pivot high at entry signal - close at entry signal) * higher target multiple