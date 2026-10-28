Calculation: Bullish FVG = current low > high two bars ago AND previous close > previous open
Calculation: Bearish FVG = current high < low two bars ago AND previous close < previous open
Calculation: Highest high since entry = highest high from the entry bar through the current bar
Calculation: Lowest low since entry = lowest low from the entry bar through the current bar
Long: position is flat AND volume > 20-bar SMA of volume AND ADX(14) > 20 AND (Bullish FVG OR (MACD(12,26,9) line crosses above its signal line AND RSI(14) < 40))
Short: position is flat AND volume > 20-bar SMA of volume AND ADX(14) > 20 AND (Bearish FVG OR (MACD(12,26,9) line crosses below its signal line AND RSI(14) > 60))
Exit: Long, low <= entry price minus stop distance OR (high since entry >= entry price plus trail activation distance AND low <= highest high since entry minus trail offset)
Exit: Short, high >= entry price plus stop distance OR (low since entry <= entry price minus trail activation distance AND high >= lowest low since entry plus trail offset)