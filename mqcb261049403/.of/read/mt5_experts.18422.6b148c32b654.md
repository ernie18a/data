Calculation: Channel = initialize the middle to the first close; for each subsequent bar, set the middle to close × (1 − percentage) if that exceeds the previous middle, otherwise to close × (1 + percentage) if that is below the previous middle, otherwise retain the previous middle. Upper and lower channel values are the middle multiplied by (1 + percentage) and (1 − percentage), respectively; compare each bar with channel values from a parameterized number of bars earlier.
Long: Chart-timeframe close > upper channel
Short: Chart-timeframe close < lower channel
Long: Selected signal bar close > upper channel AND preceding signal bar close <= its upper channel
Short: Selected signal bar close < lower channel AND preceding signal bar close >= its lower channel
Exit: short, selected signal bar close > upper channel
Exit: long, selected signal bar close < lower channel
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance
Calculation: Selected signal bar = a parameterized bar on the indicator timeframe, which may be higher or lower than the chart timeframe; use the last completed bar by default, or the still-forming bar when configured. Evaluate completed-bar signals when a new indicator-timeframe bar begins.