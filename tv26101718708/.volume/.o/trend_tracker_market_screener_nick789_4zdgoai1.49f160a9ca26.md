Calculation: Source = (open + high + low + close) / 4
Calculation: Center = fast EMA of source in Scalp mode; average of fast and slow EMAs in Trend mode, with the fast EMA using the shorter lookback
Calculation: ATR bands = center ± ATR × multiplier
Calculation: Tracker direction = bullish if source exceeds the previous bar’s upper ATR band, bearish if it falls below the previous bar’s lower ATR band, otherwise retain the prior direction; initialize bullish
Long: Tracker direction = bullish
Short: Tracker direction = bearish