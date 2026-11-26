Calculation: range high = Highest(high, breakout lookback, previous completed chart bars)
Calculation: range low = Lowest(low, breakout lookback, previous completed chart bars)
Calculation: MA1 = moving average(close, independent lookback A, current chart bar); MA = moving average(close, independent lookback B, current chart bar)
Calculation: MFI = MFI(lookback, current chart bar)
Calculation: signal state = side of the latest signal, initially flat; evaluate Long first and update state, then evaluate Short and update state
Calculation: long stop level = range low − long spread multiplier × spread in price units while signal state is long; if below the previous long stop while no previous short stop exists, retain the previous long stop
Calculation: short stop level = range high + short spread multiplier × spread in price units while signal state is short; if above the previous short stop while no previous long stop exists, retain the previous short stop
Long: signal state before the Long check is flat or short AND ((high >= range high AND close > MA1 AND close > MA AND high > MA AND MFI >= upper MFI threshold) OR (close >= previous chart bar's short stop level AND high > range high))
Short: signal state after the Long check is flat or long AND ((low <= range low AND close < MA1 AND close < MA AND low < MA AND MFI <= lower MFI threshold) OR (close <= previous chart bar's long stop level AND low < range low))