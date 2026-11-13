Calculation: volume z-score = (volume - SMA of volume over lookback) / standard deviation of volume over the same lookback (0 if the standard deviation is 0 or unavailable)
Calculation: range = high - low
Calculation: body ratio = abs(close - open) / range
Calculation: upper wick ratio = (high - max(open, close)) / range
Calculation: lower wick ratio = (min(open, close) - low) / range
Calculation: prior high extreme = highest high of the N bars before the current bar (current bar excluded)
Calculation: prior low extreme = lowest low of the N bars before the current bar (current bar excluded)
Calculation: ATR = Average True Range
Long: volume z-score >= volume threshold AND body ratio <= min(max body ratio, 1 - min wick ratio) AND lower wick ratio >= min wick ratio AND abs(low - prior low extreme) <= cluster multiple * ATR AND close > low + 0.25 * range
Short: volume z-score >= volume threshold AND body ratio <= min(max body ratio, 1 - min wick ratio) AND upper wick ratio >= min wick ratio AND abs(high - prior high extreme) <= cluster multiple * ATR AND close < high - 0.25 * range