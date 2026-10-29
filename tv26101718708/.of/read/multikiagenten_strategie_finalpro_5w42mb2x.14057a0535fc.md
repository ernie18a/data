Calculation: Long evidence score = weighted sum of bullish trend, oversold RSI, volume spike, bullish institutional signal, and upward Fibonacci cross; institutional weight > trend weight > volume weight > RSI weight = Fibonacci weight
Calculation: Short evidence score = weighted sum of bearish trend, overbought RSI, volume spike, bearish institutional signal, and downward Fibonacci cross; institutional weight > trend weight > volume weight > RSI weight = Fibonacci weight
Calculation: Bullish trend = shorter-term EMA > intermediate-term EMA > longer-term EMA AND close > shorter-term EMA
Calculation: Bearish trend = shorter-term EMA < intermediate-term EMA < longer-term EMA AND close < shorter-term EMA
Calculation: Bullish institutional signal = bullish fair value gap OR close at or below the previous bar's rolling low
Calculation: Bearish institutional signal = bearish fair value gap OR close at or above the previous bar's rolling high
Calculation: Bullish fair value gap = high from two bars ago < low from the previous bar AND close > low from the previous bar
Calculation: Bearish fair value gap = low from two bars ago > high from the previous bar AND close < high from the previous bar
Calculation: Upward Fibonacci cross = close above the upper Fibonacci retracement level AND previous close at or below that level
Calculation: Downward Fibonacci cross = close below the lower Fibonacci retracement level AND previous close at or above that level
Calculation: Volume spike = volume > moving average of volume
Long: Long evidence score >= minimum score threshold
Short: Short evidence score >= minimum score threshold
Calculation: Long stop = maximum of previous stop and low minus an ATR multiple; initialize from entry-bar close minus an ATR multiple
Calculation: Long target = entry-bar close plus an ATR multiple
Calculation: Short stop = minimum of previous stop and high plus an ATR multiple; initialize from entry-bar close plus an ATR multiple
Calculation: Short target = entry-bar close minus an ATR multiple
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target