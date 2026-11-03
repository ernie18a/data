Calculation: Fast and slow EMAs = exponential moving averages of close, with the fast lookback shorter than the slow lookback; evaluate on the configured indicator timeframe using completed bars 1 and 2.
Calculation: Typical-price CCI = commodity channel index of typical price on the configured indicator timeframe, evaluated on completed bars 1 and 2.
Calculation: Open-price EMAs = exponential moving averages of open at short, medium, and long lookbacks, with short < medium < long; evaluate on the configured indicator timeframe at the specified bar shifts.
Calculation: Open-price MACD main line = MACD main line calculated from open prices on the configured indicator timeframe.
Calculation: Perceptron score = weighted sum of four configured features: either close at each of four progressively later completed-bar offsets minus open at the next offset; stochastic main line minus 50 at four progressively later completed-bar offsets; or CCI at four progressively later completed-bar offsets. Use the configured feature mode and weights on the configured indicator timeframe.
Calculation: Direction score = weighted sum of the Accelerator Oscillator at four progressively later completed-bar offsets on the configured indicator timeframe, using configured coefficients.
Calculation: MA trend = up when same-lookback moving averages of close > weighted price > typical price > median price > open, down when all four inequalities are reversed, otherwise neutral; use the configured MA type on the configured indicator timeframe, current forming bar.
Calculation: MACD main line uses open prices on the configured indicator timeframe; compare consecutive bars, including the current forming bar and the last completed bar.
Long: Fast EMA at bar 1 > slow EMA at bar 1 AND fast EMA at bar 2 < slow EMA at bar 2 AND slow EMA at bar 1 > slow EMA at bar 2.
Short: Fast EMA at bar 1 < slow EMA at bar 1 AND fast EMA at bar 2 > slow EMA at bar 2 AND slow EMA at bar 1 < slow EMA at bar 2.
Long: Typical-price CCI at bar 1 > the negative configured threshold AND typical-price CCI at bar 2 < that negative threshold.
Short: Typical-price CCI at bar 1 < the configured positive threshold AND typical-price CCI at bar 2 > that positive threshold.
Long: Fast EMA at bar 1 > slow EMA at bar 1 AND fast EMA at bar 2 < slow EMA at bar 2 AND slow EMA at bar 1 > slow EMA at bar 2.
Short: Fast EMA at bar 1 < slow EMA at bar 1 AND fast EMA at bar 2 > slow EMA at bar 2 AND slow EMA at bar 1 < slow EMA at bar 2.
Long: Open-price EMA at long lookback rises from bar 1 to forming bar 0 AND open-price EMA at medium lookback rises AND is above the long EMA AND open-price EMA at short lookback rises AND is above the medium EMA AND MACD main line rises from bar 1 to forming bar 0 AND is above its configured positive threshold.
Short: Open-price EMA at long lookback falls from bar 1 to forming bar 0 AND open-price EMA at medium lookback falls AND is below the long EMA AND open-price EMA at short lookback falls AND is below the medium EMA AND MACD main line falls from bar 1 to forming bar 0 AND is below the negative configured threshold.
Long: Typical-price CCI at bar 1 > the configured positive threshold AND typical-price CCI at bar 2 < that threshold.
Short: Typical-price CCI at bar 1 < the negative configured threshold AND typical-price CCI at bar 2 > that threshold.
Long: Perceptron score >= configured long-entry threshold.
Short: Perceptron score <= configured short-entry threshold.
Long: Direction score >= configured long-entry threshold.
Short: Direction score <= configured short-entry threshold.
Long: MA trend changes from down to up.
Short: MA trend changes from up to down.
Exit: Long, fast EMA at bar 1 < slow EMA at bar 1.
Exit: Short, fast EMA at bar 1 > slow EMA at bar 1.
Exit: Long, the most recent historical CCI threshold-crossing entry signal is short.
Exit: Short, the most recent historical CCI threshold-crossing entry signal is long.
Exit: Long, completed chart-timeframe close < open-price EMA at the configured lookback on the indicator timeframe, current forming bar.
Exit: Short, completed chart-timeframe close > open-price EMA at the configured lookback on the indicator timeframe, current forming bar.
Exit: Long, after scanning backward to the most recent CCI threshold-crossing entry signal and adjusting a trailing CCI level upward by its configured increment when historical CCI exceeds that level by more than twice the increment, current completed-bar CCI < the adjusted level.
Exit: Short, after scanning backward to the most recent CCI threshold-crossing entry signal and adjusting a trailing CCI level downward by its configured increment when historical CCI is below that level by more than twice the increment, current completed-bar CCI > the adjusted level.
Exit: Long, perceptron score <= configured long-exit threshold.
Exit: Short, perceptron score >= configured short-exit threshold.
Exit: Long, direction score <= configured long-exit threshold.
Exit: Short, direction score >= configured short-exit threshold.
Exit: Long, MA trend is down and the remembered trend is up.
Exit: Short, MA trend is up and the remembered trend is down.