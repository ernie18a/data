Calculation: Daily channel = highest high and lowest low during the configured daily time range, carried forward for the rest of that day; calculated from signal-timeframe bars (which may be higher or lower than the chart timeframe). Use the last completed signal-timeframe bar and its preceding bar.
Long: close > upper channel AND preceding bar close <= its upper channel
Short: close < lower channel AND preceding bar close >= its lower channel
Exit: Long, close < lower channel OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, close > upper channel OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance