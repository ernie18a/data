Calculation: Timeframe sine = for each of eight ordered timeframes, the requested close plus chart-timeframe ATR multiplied by an amplitude parameter and by sin(2π × chart bar index / that timeframe's period + its phase); periods increase with timeframe and phases increase in equal steps. On historical bars, use the last completed higher-timeframe bar, the last lower-timeframe bar within the chart bar, or the chart bar itself when timeframes match.
Calculation: Rising sine count = number of timeframe sines greater than their respective previous chart-bar values; non-rising sine count = eight minus rising sine count; composite sine = mean of the eight sines.
Calculation: Rising regression count = number of eight linear regression values of chart close, evaluated at the current bar with successively longer lookbacks, that exceed their respective previous values; non-rising regression count = eight minus rising regression count.
Calculation: Volume fusion = mean of rolling min-max normalizations of EMA of merged-bar delta, EMA of cumulative merged-bar delta, and EMA of cumulative merged-bar OBV step. Merged-bar volume is the sum of volume over a rolling window; delta is that volume with the sign of current close minus the window's first open; OBV step is that volume with the sign of current close minus previous close. Each normalization is (value minus rolling minimum) / (rolling maximum minus rolling minimum), or the midpoint when the range is zero. The delta EMA and fusion EMA share a smoothing length; the two cumulative-series EMAs share a trend length.
Calculation: Volume resistance break = volume fusion crosses above the previous bar's rolling maximum of volume fusion; volume support break = volume fusion crosses below the previous bar's rolling minimum of volume fusion, using the same lookback.
Calculation: Power score = rounded weighted sum of sine, regression, trend, volume, RSI, and ATR component scores, with weights summing to one. Sine and regression scores are the respective rising counts divided by eight and scaled to the score range. Trend score is maximum when close is above its EMA, minimum when below, and midpoint otherwise. RSI score is maximum at or above its upper threshold, minimum at or below its lower threshold, and midpoint otherwise. Volume score is maximum on a resistance break, minimum on a support break, an upper intermediate value when volume fusion is above its EMA, a lower intermediate value when below, and midpoint otherwise, in that priority order. ATR score is maximum when ATR is above its SMA and close is above open, minimum when ATR is above its SMA and close is below open, and midpoint otherwise.
Calculation: Last signal = initially neutral; set to long when the filtered power long decision occurs and to short when the filtered power short decision occurs; retain its value otherwise.
Long: Power score >= upper power threshold AND composite sine > previous composite sine AND close > close EMA AND rising regression count >= agreement threshold AND volume support break = false AND last signal != long.
Short: Power score <= lower power threshold AND composite sine <= previous composite sine AND close < close EMA AND non-rising regression count >= agreement threshold AND volume resistance break = false AND last signal != short.
Long: Rising sine count >= agreement threshold AND rising regression count >= agreement threshold.
Short: Non-rising sine count >= agreement threshold AND non-rising regression count >= agreement threshold.
Long: Composite sine > previous composite sine.
Short: Composite sine <= previous composite sine.
Long: Rising sine count >= agreement threshold.
Short: Non-rising sine count >= agreement threshold.
Long: Rising regression count >= agreement threshold.
Short: Non-rising regression count >= agreement threshold.
Long: Close > close EMA.
Short: Close <= close EMA.
Long: RSI > upper display threshold.
Short: RSI < lower display threshold.
Long: Volume resistance break = true OR volume support break = false AND volume fusion > volume fusion EMA.
Short: Volume support break = true OR volume resistance break = false AND volume fusion < volume fusion EMA.
Long: Power score >= upper power threshold.
Short: Power score <= lower power threshold.