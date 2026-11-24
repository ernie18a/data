Calculation: Recent pivot high = latest confirmed Pivot High(high, pivot lookback, pivot lookback)
Calculation: Recent pivot low = latest confirmed Pivot Low(low, pivot lookback, pivot lookback)
Calculation: Active fib setup = while no setup is active, a bullish structure break stores (recent pivot low, recent pivot high) and a bearish structure break stores (recent pivot high, recent pivot low); retain the setup until position exit
Calculation: Fib entry level = first swing anchor + (second swing anchor - first swing anchor) * entry retracement parameter
Calculation: Fib take-profit level = first swing anchor + (second swing anchor - first swing anchor) * take-profit parameter
Calculation: Fib extension level = first swing anchor + (second swing anchor - first swing anchor) * extension ratio
Calculation: Bullish run count = consecutive count of bars where close > close[comparison lookback], reset to zero otherwise
Calculation: Bearish run count = consecutive count of bars where close < close[comparison lookback], reset to zero otherwise
Calculation: Late bullish count = bullish run count - valuewhen(bullish run count < bullish run count[1], bullish run count, previous occurrence)
Calculation: Late bearish count = bearish run count - valuewhen(bearish run count < bearish run count[1], bearish run count, previous occurrence)
Calculation: Volume climax = volume[1] > SMA(volume, volume-average lookback) * volume-spike multiplier
Calculation: Doji candle = high > low AND abs(close - open) / (high - low) < doji-body fraction limit
Long: (bar-close confirmation enabled AND close[1] > recent pivot high[1] AND close[2] <= recent pivot high[2]) OR (bar-close confirmation disabled AND close crosses above recent pivot high)
Short: (bar-close confirmation enabled AND close[1] < recent pivot low[1] AND close[2] >= recent pivot low[2]) OR (bar-close confirmation disabled AND close crosses below recent pivot low)
Long: low < recent pivot low AND close > recent pivot low AND low = lowest(low, twice the pivot lookback)
Short: high > recent pivot high AND close < recent pivot high AND high = highest(high, twice the pivot lookback)
Long: low > high[gap lookback]
Short: high < low[gap lookback]
Long: (full-count mode active AND bullish run count equals a full-count marker level) OR (late-stage mode active AND late bullish count equals a late-stage marker level) OR late bullish count equals the GK 9 alert level OR bullish run count equals the B-signal level OR late bullish count equals the B-signal level
Short: (full-count mode active AND bearish run count equals a full-count marker level) OR (late-stage mode active AND late bearish count equals a late-stage marker level) OR late bearish count equals the GK 9 alert level OR bearish run count equals the B-signal level OR late bearish count equals the B-signal level
Long: Volume climax AND close[1] < open[1] AND Doji candle
Short: Volume climax AND close[1] > open[1] AND Doji candle
Long: close > the low of an untriggered bullish B-signal line created when late bullish count reaches the B-signal level, while the line is retained and unexpired
Short: close < the high of an untriggered bearish B-signal line created when late bearish count reaches the B-signal level, while the line is retained and unexpired
Long: position is flat AND an active bullish fib setup exists AND high has reached the fib extension level AND low has reached the second swing anchor since that extension touch AND low <= fib entry level AND (liquidity-sweep requirement is disabled OR a bullish sweep remains recent)
Short: position is flat AND an active bearish fib setup exists AND low has reached the fib extension level AND high has reached the second swing anchor since that extension touch AND high >= fib entry level AND (liquidity-sweep requirement is disabled OR a bearish sweep remains recent)
Exit: long, high >= fib take-profit level OR low <= first swing anchor
Exit: short, low <= fib take-profit level OR high >= first swing anchor