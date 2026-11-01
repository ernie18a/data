Calculation: CCI = commodity channel index of a selected price source, defaulting to (high + low + close) / 3.
Calculation: CCI average = a selected moving average of CCI.
Calculation: CCI slope = current CCI minus previous CCI, optionally smoothed by an EMA.
Calculation: Histogram = CCI minus CCI average. Its state is LAUNCH on an upward zero cross; FLIP on a downward zero cross; otherwise SURGE when it rises and FADE when it falls. On an unchanged bar, retain the previous state.
Calculation: Slope decay = absolute CCI slope divided by its highest absolute value over a lookback, or 1 if that highest value is zero.
Calculation: Absorption = slope decay crosses below a threshold while CCI is beyond a positive or negative extreme threshold.
Calculation: CCI volatility ratio = the rolling CCI high minus rolling CCI low, divided by the longer-lookback SMA of that range; use 1 when the SMA is not positive.
Calculation: Velocity envelope = SMA of CCI plus or minus a multiplier times the standard deviation of CCI over the same lookback.
Calculation: Confirmed pivot = a high or low with the specified number of bars on each side; evaluate it only when the right-hand bars have completed.
Calculation: Divergence = compare the latest two qualifying, consecutive paired price and CCI pivots of the same type. Both pivots in each pair must occur on the same bar, their CCI values must both exceed the positive extreme threshold for highs or both fall below the negative extreme threshold for lows, and their separation must be positive and no greater than the maximum span. Bullish divergence is a lower price low with a higher CCI low OR a lower price high with a higher CCI high. Bearish divergence is a higher price high with a lower CCI high OR a higher price low with a lower CCI low. Calculate separate fast and slow versions, with a shorter pivot lookback for fast and longer pivot lookback for slow; each has its own extreme threshold and maximum span.
Calculation: Divergence confluence = the latest fast and slow divergences of the same direction have pivot-bar indices greater than zero and separated by no more than a window. A new confluence occurs when this condition becomes true after being false; retain the latest divergence pivot index for each direction and speed until replaced.
Calculation: Intelligence pattern = the first matching condition in this priority order: FADE with absorption; SURGE with absolute slope above its strong threshold and CCI volatility ratio at or above its expansion threshold; FADE with absolute slope at or below its strong threshold and absolute CCI above an extreme threshold; CCI above an overbought threshold with slope below negative twice the strong threshold; CCI below a negative oversold threshold with slope above twice the strong threshold; absorption with SURGE; otherwise no actionable pattern. An intelligence decision occurs only when the pattern changes and at least a minimum number of bars have elapsed since the last actionable intelligence decision; initialize that last bar index to zero. The two directional full-trend conditions share one pattern, as do the two directional absorption-and-FADE conditions.
Long: CCI slope > 0.
Short: CCI slope < 0.
Long: CCI > CCI average.
Short: CCI <= CCI average.
Long: A confirmed CCI pivot low < negative pivot threshold.
Short: A confirmed CCI pivot high > positive pivot threshold.
Long: A fast or slow bullish divergence is confirmed.
Short: A fast or slow bearish divergence is confirmed.
Long: New bullish divergence confluence.
Short: New bearish divergence confluence.
Long: Histogram > 0.
Short: Histogram < 0.
Long: CCI crosses above the upper velocity envelope.
Short: CCI crosses below the lower velocity envelope.
Long: Absorption AND CCI < negative extreme threshold.
Short: Absorption AND CCI > positive extreme threshold.
Long: Chart CCI > 0 AND CCI on each of two higher timeframes > 0; use the last completed bar on each higher timeframe, with one higher timeframe longer than the other.
Short: Chart CCI < 0 AND CCI on each of two higher timeframes < 0; use the last completed bar on each higher timeframe, with one higher timeframe longer than the other.
Long: Intelligence decision AND FADE with absorption AND CCI < negative extreme threshold.
Short: Intelligence decision AND FADE with absorption AND CCI > positive extreme threshold.
Long: Intelligence decision AND SURGE with strong slope and expanded CCI volatility ratio AND CCI slope > 0.
Short: Intelligence decision AND SURGE with strong slope and expanded CCI volatility ratio AND CCI slope < 0.
Exit: long, slow regular bearish divergence is confirmed.
Exit: short, slow regular bullish divergence is confirmed.
Exit: long, intelligence decision AND FADE with absorption AND CCI > positive extreme threshold.
Exit: short, intelligence decision AND FADE with absorption AND CCI < negative extreme threshold.
Exit: long, intelligence decision AND FADE AND absolute CCI slope <= strong slope threshold AND CCI > positive extreme threshold.
Exit: short, intelligence decision AND FADE AND absolute CCI slope <= strong slope threshold AND CCI < negative extreme threshold.
Exit: long, intelligence decision AND CCI > overbought threshold AND CCI slope < negative twice the strong slope threshold.
Exit: short, intelligence decision AND CCI < negative oversold threshold AND CCI slope > twice the strong slope threshold.