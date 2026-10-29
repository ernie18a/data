Calculation: Double-smoothed price = apply the configured first smoothing to the selected OHLC-derived price, then apply the configured second smoothing to that result; round to the configured precision. Calculate on the configured signal timeframe, whether higher, lower, or equal to the chart timeframe, using completed bars.
Calculation: Trend state = rising when double-smoothed price increases, falling when it decreases, and otherwise retain the preceding state; initially neutral.
Long: Trend state on the latest completed signal bar is rising AND trend state on the preceding completed signal bar is not rising
Short: Trend state on the latest completed signal bar is falling AND trend state on the preceding completed signal bar is not falling
Exit: long, Trend state on the latest completed signal bar is falling
Exit: short, Trend state on the latest completed signal bar is rising