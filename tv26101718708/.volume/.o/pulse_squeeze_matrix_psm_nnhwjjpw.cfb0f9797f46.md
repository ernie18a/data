Calculation: Rolling range = highest high minus lowest low over the lookback
Calculation: Fibonacci 0.382 = rolling highest high minus 0.382 times the rolling range
Calculation: Fibonacci 0.618 = rolling highest high minus 0.618 times the rolling range
Calculation: Bollinger Band width = (upper band minus lower band) divided by the simple moving average of close; bands use the same lookback and a configurable standard-deviation multiplier
Calculation: Squeeze = Bollinger Band width is less than 1.2 times its rolling lowest value AND ATR is less than its simple moving average over the squeeze lookback
Calculation: ATR buffer = ATR times a configurable multiplier
Long: close crosses above Fibonacci 0.382 plus ATR buffer OR (close is above its 50-bar simple moving average AND squeeze is false)
Short: close crosses below Fibonacci 0.618 minus ATR buffer OR (close is below its 50-bar simple moving average AND squeeze is false)