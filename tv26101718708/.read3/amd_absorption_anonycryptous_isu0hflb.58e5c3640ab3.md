Calculation: range percent = (Highest(high, accumulation lookback) - Lowest(low, accumulation lookback)) / Lowest(low, accumulation lookback) * 100
Calculation: in session = bar time is within an enabled Asia, London, or New York session window
Calculation: accumulation = range percent <= max accumulation range AND in session
Calculation: accumulation low = Lowest(low, accumulation lookback) on the latest bar where accumulation is true, unset on a session change and after a bull setup
Calculation: accumulation high = Highest(high, accumulation lookback) on the latest bar where accumulation is true, unset on a session change and after a bear setup
Calculation: bullish gap = low - high[2] > ATR(ATR length) * min FVG size AND close > accumulation low
Calculation: bearish gap = low[2] - high > ATR(ATR length) * min FVG size AND close < accumulation high
Calculation: absorption(n) = high[n] - low[n] > 0 AND abs(close[n] - open[n]) / (high[n] - low[n]) <= max body/range ratio AND volume[n] > SMA(volume, volume average length)[n] * min volume multiplier
Calculation: manipulation window = accumulation high is set AND in session AND NOT accumulation AND bars since the latest accumulation bar <= manipulation search window
Calculation: bull sweep = manipulation window AND accumulation low is set AND (bull armed[1] OR low < accumulation low AND NOT bear armed)
Calculation: bear sweep = manipulation window AND (bear armed[1] OR high > accumulation high AND NOT bull armed[1])
Calculation: bull setup = bull sweep AND bullish gap
Calculation: bear setup = bear sweep AND bearish gap
Calculation: bull armed = bull sweep AND NOT bullish gap
Calculation: bear armed = bear sweep AND NOT bearish gap
Calculation: absorption passed = NOT absorption filter enabled OR absorption(1)
Calculation: absorption highlight = absorption filter enabled AND absorption(0) AND (bull armed OR bear armed)
Calculation: latest setup bullish = bull setup OR (latest setup bullish[1] AND NOT bear setup)
Calculation: latest setup bearish = bear setup OR (latest setup bearish[1] AND NOT bull setup)
Calculation: distribution window = bars since the latest bull or bear setup <= distribution box width AND no session change since that setup
Long: bull setup AND absorption passed
Long: bull setup
Long: latest setup bullish
Long: distribution window AND latest setup bullish AND NOT absorption highlight
Long: bull armed AND NOT distribution window AND NOT absorption highlight
Long: absorption highlight AND bull armed
Short: bear setup AND absorption passed
Short: bear setup
Short: latest setup bearish
Short: distribution window AND latest setup bearish AND NOT absorption highlight
Short: bear armed AND NOT distribution window AND NOT absorption highlight
Short: absorption highlight AND bear armed