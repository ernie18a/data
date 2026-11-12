Calculation: candle = the bar of a timeframe equal to or higher than the chart timeframe, taking the bar still forming (current, not the last completed); the chart bar itself when the timeframes are equal
Calculation: range = max(high - low, minimum tick); bodyPct = abs(close - open) / range; upperPct = (high - max(open, close)) / range; lowerPct = (min(open, close) - low) / range
Calculation: neutral candle = bodyPct <= small doji threshold OR (upperPct >= large rejection threshold AND upperPct > lowerPct) OR (lowerPct >= large rejection threshold AND lowerPct > upperPct)
Long: candle close >= candle open AND NOT neutral candle
Short: candle close < candle open AND NOT neutral candle