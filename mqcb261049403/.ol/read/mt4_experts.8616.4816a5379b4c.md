Calculation: Support = low of the configured-timeframe bar at the numBars-th completed-bar offset; Resistance = high of that same bar
Calculation: EMA = exponential moving average of close on the configured timeframe, using the bar still forming
Calculation: Fibonacci range = high minus low, using the high and low from the configured daily bars
Calculation: Fibonacci 23.6% and 76.4% levels = range fractions measured from the low when the daily high occurred first on the chart; otherwise measured down from the high
Calculation: High-first = the current chart bar’s high matches the daily high before any chart bar’s low matches the daily low; otherwise low-first
Long: close > EMA AND close > Resistance AND ((high-first AND close > Fibonacci 23.6% AND close < Fibonacci 76.4%) OR (low-first AND close < Fibonacci 23.6% AND close > Fibonacci 76.4%))
Short: close < EMA AND close < Support AND ((high-first AND close > Fibonacci 23.6% AND close < Fibonacci 76.4%) OR (low-first AND close < Fibonacci 23.6% AND close > Fibonacci 76.4%)) OR close > EMA AND close < Resistance AND low-first AND close > Fibonacci 23.6% OR close < EMA AND close < Resistance AND high-first AND close > Fibonacci 76.4%
Exit: long, close < Support
Exit: short, close > Resistance