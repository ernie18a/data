Calculation: Confirmed swing high/low = a pivot high/low using equal numbers of bars on both sides, known only after the right-side bars close; for equal extremes, use the most recent extreme. Breaks and sweeps on a bar use the latest swings known before that bar. On confirmation, replace the corresponding latest swing, mark it broken if the confirmation close is already beyond it, and reset its swept flag. A subsequent close beyond an unbroken swing marks it broken; the first qualifying sweep marks it swept.
Calculation: Completed session range = the highest high and lowest low of chart bars whose opening times fall within a configured session and timezone. Make the range available on the first bar outside the session, retire it when the next session begins, and reset separate high- and low-swept flags. Track each configured session independently; sessions apply only to intraday chart bars.
Calculation: Valid bullish order block = the nearest bearish candle within the configured lookback and on or after the broken swing high, provided no close from the following bar through the break bar is below that candle's low. Valid bearish order block = the nearest bullish candle within the configured lookback and on or after the broken swing low, provided no close from the following bar through the break bar is above that candle's high. If the nearest opposite candle fails validation, do not search farther.
Long: The shorter-term moving average of the selected price source is above the longer-term moving average.
Short: The shorter-term moving average of the selected price source is below the longer-term moving average.
Long: Supertrend indicates an uptrend.
Short: Supertrend indicates a downtrend.
Long: RSI is at or below its oversold threshold.
Short: RSI is at or above its overbought threshold.
Long: MACD is above its signal line.
Short: MACD is at or below its signal line.
Long: MACD histogram is at or above zero.
Short: MACD histogram is below zero.
Long: A newly confirmed swing high is above the preceding confirmed swing high OR a newly confirmed swing low is above the preceding confirmed swing low.
Short: A newly confirmed swing high is below the preceding confirmed swing high OR a newly confirmed swing low is below the preceding confirmed swing low.
Long: Close is above the latest unbroken confirmed swing high.
Short: Close is below the latest unbroken confirmed swing low.
Long: The latest confirmed swing low is unbroken and unswept AND low is below it AND close is above it.
Short: The latest confirmed swing high is unbroken and unswept AND high is above it AND close is below it.
Long: Low is above the high two bars earlier AND their difference is at least the configured multiple of ATR.
Short: High is below the low two bars earlier AND their difference is at least the configured multiple of ATR.
Long: Close is above the latest unbroken confirmed swing high AND a valid bullish order block exists.
Short: Close is below the latest unbroken confirmed swing low AND a valid bearish order block exists.
Long: Outside a configured session, the completed session low has not yet been swept AND low is below that low AND close is above that low AND close is below the completed session high; then mark the session low swept.
Short: Outside a configured session, the completed session high has not yet been swept AND high is above that high AND close is below that high AND close is above the completed session low; then mark the session high swept.