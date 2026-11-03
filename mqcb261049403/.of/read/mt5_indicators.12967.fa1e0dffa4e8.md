Calculation: Upper and lower bounds = the highest high and lowest low over the lookback including the evaluated bar. Offset = (upper bound - lower bound) multiplied by a shift parameter.
Calculation: Direction = initially neutral; on each completed bar, set to short if close < lower bound + offset AND prior direction != short; otherwise set to long if close > upper bound - offset AND prior direction != long; otherwise retain the prior direction. For a forming bar, calculate its direction from the last completed bar's direction without committing the update.
Long: Chart close > chart upper bound - chart offset AND prior completed chart direction != long AND (chart close >= chart lower bound + chart offset OR prior completed chart direction = short)
Short: Chart close < chart lower bound + chart offset AND prior completed chart direction != short
Long: Higher-timeframe forming bar direction = long
Short: Higher-timeframe forming bar direction = short