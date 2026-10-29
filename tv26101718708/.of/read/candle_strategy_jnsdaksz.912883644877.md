Calculation: Candle number = sequential chart-timeframe bar number within the day, starting at 1
Calculation: Long stop price = lowest low from the first chart-timeframe bar of the day through the selected candle-number bar
Calculation: Short stop price = highest high from the first chart-timeframe bar of the day through the selected candle-number bar
Long: candle number equals the configured trade candle number AND close > high of the first chart-timeframe bar of the day AND configured trade direction is Long or Both
Short: candle number equals the configured trade candle number AND close < low of the first chart-timeframe bar of the day AND configured trade direction is Short or Both
Exit: Long, low <= long stop price OR current bar is the last bar of the day
Exit: Short, high >= short stop price OR current bar is the last bar of the day