Calculation: EMA = exponential moving average of close using a configurable period
Calculation: Higher-timeframe bias = 1 when that timeframe’s close is above its EMA, -1 when below, and 0 when equal; use the current higher-timeframe bar, which may still be forming
Calculation: Daily support/resistance = among the prior daily bars within the configured lookback, select the closest resistance above the current daily close or support below it that has at least the configured minimum touches. A resistance touch has a high within the configured ATR tolerance of the candidate high and a close below it; a support touch has a low within tolerance of the candidate low and a close above it. Tolerance is daily ATR(14) multiplied by a configurable factor. Use the current daily bar, which may still be forming
Calculation: Buy score = 2 if chart close > EMA, plus 3 if a bullish break occurs, plus 2 if close > open, plus 1 for each bullish bias on the three successively longer higher timeframes; otherwise each contribution is 0
Calculation: Sell score = 2 if chart close < EMA, plus 3 if a bearish break occurs, plus 2 if close < open, plus 1 for each bearish bias on the three successively longer higher timeframes; otherwise each contribution is 0
Calculation: Final score = the greater of the buy score and sell score
Long: Chart bar is confirmed when candle-close confirmation is enabled AND valid daily resistance exists AND close > daily resistance
Long: Buy score > sell score AND final score >= 7
Long: Chart bar is confirmed when candle-close confirmation is enabled AND close > EMA AND valid daily resistance exists AND close > daily resistance AND final score >= 7
Short: Chart bar is confirmed when candle-close confirmation is enabled AND valid daily support exists AND close < daily support
Short: Sell score > buy score AND final score >= 7
Short: Chart bar is confirmed when candle-close confirmation is enabled AND close < EMA AND valid daily support exists AND close < daily support AND final score >= 7