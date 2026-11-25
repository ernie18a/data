Calculation: candle-volume score = 3 * (close[0] - open[0]) * volume[0]
Long: candle-volume score > OpenLevel AND candle-volume score >= -OpenLevel AND candle-volume score >= OpenLevel - CloseLevelDif
Short: candle-volume score < -OpenLevel AND candle-volume score <= OpenLevel AND candle-volume score <= -(OpenLevel - CloseLevelDif)
Exit: long, candle-volume score < OpenLevel - CloseLevelDif
Exit: short, candle-volume score > -(OpenLevel - CloseLevelDif)