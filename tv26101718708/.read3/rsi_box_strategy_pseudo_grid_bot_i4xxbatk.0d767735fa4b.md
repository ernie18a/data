Calculation: Upper boundary = value of VWMA(Highest(source, lookback), lookback) at the most recent bar when RSI(source, lookback) crosses below the overbought threshold
Calculation: Lower boundary = value of VWMA(Lowest(source, lookback), lookback) at the most recent bar when RSI(source, lookback) crosses above the oversold threshold
Calculation: Center line = average(upper boundary, lower boundary)
Calculation: Upper inner line = average(center line, upper boundary)
Calculation: Lower inner line = average(center line, lower boundary)
Calculation: Nearest grid line = the closest of the upper boundary, upper inner line, center line, lower inner line, and lower boundary to source
Long: source crosses above the grid line immediately above the nearest grid line
Short: shorts are enabled AND source crosses below the grid line immediately below the nearest grid line
Exit: long, shorts are disabled AND source crosses below the grid line immediately below the nearest grid line