Calculation: Bullish engulfing = previous bar close < previous bar open AND current bar close > current bar open AND current bar open <= previous bar close AND current bar close >= previous bar open
Calculation: Stop price = low of the bullish engulfing bar * (1 - stop buffer percentage)
Calculation: Volume target = close of the bar with the highest volume in the trailing lookback window; if tied, use the oldest tied bar
Calculation: Minimum target = entry price + 2 * (entry price - stop price)
Calculation: Take-profit price = minimum target if no volume target is available, otherwise the greater of the volume target and minimum target
Long: position is flat AND bullish engulfing AND RSI < oversold threshold
Exit: long, low <= stop price OR high >= take-profit price