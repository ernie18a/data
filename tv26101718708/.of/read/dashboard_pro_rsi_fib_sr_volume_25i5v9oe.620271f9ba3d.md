Calculation: Evaluation bars = four independently evaluated, ordered timeframes. For a timeframe higher than the chart timeframe, use its last completed bar; for a lower timeframe, use the last completed intrabar within the chart bar; for the chart timeframe, use the chart bar. Calculate all inputs for each decision on that evaluation timeframe.
Calculation: Range low and range high = lowest low and highest high over the same lookback, including the evaluation bar.
Calculation: Lower and upper Fibonacci levels = range low + (range high − range low) × the lower and higher Fibonacci fractions, respectively.
Calculation: Range midpoint = (range high + range low) / 2.
Calculation: Volume value = volume × close; average volume value = simple moving average of volume value, including the evaluation bar.
Calculation: Bull score = count of true conditions among RSI above its midpoint, close at or above the lower Fibonacci level, close above the range midpoint, and volume value above average volume value.
Calculation: Bear score = count of true conditions among RSI below its midpoint, close below the lower Fibonacci level, close below the range midpoint, and volume value above average volume value.
Long: RSI > its midpoint.
Short: RSI < its midpoint.
Long: close > upper Fibonacci level.
Short: close < lower Fibonacci level.
Long: close > range midpoint.
Short: close < range midpoint.
Long: bull score >= bear score.
Short: bear score > bull score.
Long: bull score >= minimum condition count.
Short: bear score >= minimum condition count AND bull score < minimum condition count.