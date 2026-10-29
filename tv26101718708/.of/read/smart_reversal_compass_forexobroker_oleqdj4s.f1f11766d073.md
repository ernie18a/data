Calculation: Confirmed pivot high = a bar whose high is the highest within the pivot-length bars before and after it
Calculation: Confirmed pivot low = a bar whose low is the lowest within the pivot-length bars before and after it
Calculation: Bullish divergence = the latest confirmed pivot low is within the divergence lookback, is lower than the preceding confirmed pivot low, and its RSI is higher than the RSI at the preceding pivot low
Calculation: Bearish divergence = the latest confirmed pivot high is within the divergence lookback, is higher than the preceding confirmed pivot high, and its RSI is lower than the RSI at the preceding pivot high
Calculation: Volume climax = volume >= volume SMA × climax multiplier
Calculation: Bullish reversal candle = (high > low AND (min(open, close) − low) / (high − low) >= wick threshold AND close > open) OR (close > open AND close > previous high AND open < previous low)
Calculation: Bearish reversal candle = (high > low AND (high − max(open, close)) / (high − low) >= wick threshold AND close < open) OR (close < open AND close < previous low AND open > previous high)
Calculation: Support touch = a confirmed pivot low exists AND abs(low − latest confirmed pivot low) <= ATR × support tolerance
Calculation: Resistance touch = a confirmed pivot high exists AND abs(high − latest confirmed pivot high) <= ATR × support tolerance
Calculation: Bull confluence count = bullish divergence + volume climax + bullish reversal candle + support touch, counting each true condition as 1
Calculation: Bear confluence count = bearish divergence + volume climax + bearish reversal candle + resistance touch, counting each true condition as 1
Long: bull confluence count >= minimum confluences AND bull confluence count > bear confluence count AND bars since last signal >= signal cooldown AND current bar is closed
Short: bear confluence count >= minimum confluences AND bear confluence count > bull confluence count AND bars since last signal >= signal cooldown AND current bar is closed