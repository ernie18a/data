Calculation: ATR = average true range over a configurable lookback of current-timeframe bars.
Calculation: Relative volume = current volume / moving average volume over a configurable lookback of current-timeframe bars.
Calculation: Candle range = max(high - low, minimum tick); upper wick = high - max(open, close); lower wick = min(open, close) - low.
Calculation: Wick share = wick / candle range; close location = (close - low) / candle range.
Calculation: Rejection quality score = 0–100 weighted score of wick share, directional close-location quality, and candle range relative to ATR (peaking at an ideal range and penalizing ranges that are too small or too large), optionally weighted with relative-volume support. Normalize each component against configurable weak, strong, or ideal thresholds and clamp it to 0–100.
Long: lower-wick share >= minimum wick share AND close location >= minimum close quality AND lower wick > upper wick AND bullish rejection quality score >= bearish rejection quality score AND bullish rejection quality score >= minimum quality
Short: upper-wick share >= minimum wick share AND (1 - close location) >= minimum close quality AND upper wick > lower wick AND (bullish rejection candidate is false OR bearish rejection quality score > bullish rejection quality score) AND bearish rejection quality score >= minimum quality
Exit: Long, close < failure edge OR close >= target guide OR active context age > maximum context age
Exit: Short, close > failure edge OR close <= target guide OR active context age > maximum context age