Calculation: M = selected moving average of close over a lookback
Calculation: R = RSI(close, lookback)
Calculation: MACD line, signal line = MACD(close, shorter lookback, longer lookback, signal lookback)
Calculation: V = SMA(volume, lookback)
Calculation: A = ATR(lookback)
Long: close > M AND M > M[1] AND M[1] > M[2]
Short: close < M AND M < M[1] AND M[1] < M[2]
Long: low > M AND M > M[1] AND M[1] > M[2] AND (engulfing filter disabled OR (close[1] < open[1] AND close > open AND open < close[1] AND close > open[1] AND abs(close - open) > abs(close[1] - open[1]) * body multiplier)) AND (volume confirmation disabled OR volume > V * volume multiplier) AND (RSI filter disabled OR (R > oversold level AND R < overbought level)) AND (MACD confirmation disabled OR MACD line > signal line)
Short: high < M AND M < M[1] AND M[1] < M[2] AND (engulfing filter disabled OR (close[1] > open[1] AND close < open AND open > close[1] AND close < open[1] AND abs(close - open) > abs(close[1] - open[1]) * body multiplier)) AND (volume confirmation disabled OR volume > V * volume multiplier) AND (RSI filter disabled OR (R > oversold level AND R < overbought level)) AND (MACD confirmation disabled OR MACD line < signal line)
Long: R <= oversold level
Short: R >= overbought level
Long: FVG display enabled AND bullish FVG display enabled AND high[2] < low AND close[1] - open[1] > A[1] * minimum FVG size
Short: FVG display enabled AND bearish FVG display enabled AND low[2] > high AND open[1] - close[1] > A[1] * minimum FVG size
Long: MACD confirmation disabled OR MACD line > signal line
Short: MACD confirmation enabled AND MACD line < signal line