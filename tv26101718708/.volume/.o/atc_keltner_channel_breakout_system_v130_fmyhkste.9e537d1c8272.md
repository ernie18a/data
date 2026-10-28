Calculation: Upper Keltner band = HMA of close + ATR multiplied by a configurable factor
Calculation: Lower Keltner band = HMA of close - ATR multiplied by the same factor
Calculation: Volume Z-score = (current volume - trailing volume mean) / trailing volume standard deviation
Long: close > upper Keltner band AND previous close <= previous upper Keltner band AND volume Z-score >= configurable threshold
Short: close < lower Keltner band AND previous close >= previous lower Keltner band AND volume Z-score >= configurable threshold
Exit: Long, close < upper Keltner band AND close > lower Keltner band
Exit: Short, close < upper Keltner band AND close > lower Keltner band