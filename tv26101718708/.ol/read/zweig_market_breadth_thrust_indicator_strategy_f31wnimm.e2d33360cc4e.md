Calculation: Zweig breadth thrust = configurable moving average of advances / (advances + declines), using the selected exchange’s breadth series or the arithmetic mean of the NYSE, NASDAQ, and AMEX series; the breadth series comes from a higher timeframe, using the latest available bar (the forming bar in real time, the last completed bar historically), then is sampled onto the chart timeframe before averaging.
Calculation: Trailing stop = the running maximum of (bar low − bar close × stop-loss percentage), reset when there is no long position.
Long: Zweig breadth thrust crosses above the configurable entry threshold.
Exit: Long, close > entry price AND Zweig breadth thrust crosses below 0.60 when the partial-exit mode is Zweig.
Exit: Long, close > entry price AND RSI(5) crosses below 90 when the partial-exit mode is RSI.
Exit: Long, close > entry price AND Zweig breadth thrust crosses below the entry threshold.
Exit: Long, close < entry price × (1 − stop-loss percentage) when trailing stop is disabled.
Exit: Long, close < trailing stop when trailing stop is enabled.