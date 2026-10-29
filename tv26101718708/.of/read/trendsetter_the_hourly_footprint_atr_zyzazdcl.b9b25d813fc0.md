Calculation: Entry midpoint = midpoint of the last completed higher-timeframe candle
Calculation: Long stop = low of the last completed higher-timeframe candle minus its ATR multiplied by a configurable factor
Calculation: Short stop = high of the last completed higher-timeframe candle plus its ATR multiplied by a configurable factor
Calculation: Long profit targets = Fibonacci extensions of the last completed higher-timeframe candle’s range, projected upward from its low
Calculation: Short profit targets = Fibonacci extensions of the last completed higher-timeframe candle’s range, projected downward from its high
Long: last completed higher-timeframe candle close > its open
Short: last completed higher-timeframe candle close < its open
Exit: long, current bar low <= long stop OR current bar high >= either long profit target
Exit: short, current bar high >= short stop OR current bar low <= either short profit target