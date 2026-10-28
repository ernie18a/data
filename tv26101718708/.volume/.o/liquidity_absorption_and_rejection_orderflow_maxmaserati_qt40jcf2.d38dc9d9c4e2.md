Calculation: Volume ratio = current bar volume / moving average of volume over the longer lookback
Calculation: Body ratio = absolute(close - open) / max(high - low, minimum price increment)
Calculation: Upper-wick ratio = (high - max(open, close)) / max(high - low, minimum price increment)
Calculation: Lower-wick ratio = (min(open, close) - low) / max(high - low, minimum price increment)
Calculation: Tracked high/low levels = highs and lows of prior completed bars on the configured level-tracking timeframe, retained until touched or beyond the historical lookback
Long: A tracked low is touched (bar low <= level) AND close > level
Long: A tracked low is touched AND close <= level AND (volume ratio <= capitulation threshold) AND NOT (volume ratio >= absorption threshold AND body ratio > 0.6)
Long: A tracked high is touched (bar high >= level) AND close >= level AND ((volume ratio >= absorption threshold AND body ratio > 0.6) OR (volume ratio > capitulation threshold AND NOT (volume ratio >= absorption threshold AND body ratio > 0.6)))
Short: A tracked high is touched AND close < level
Short: A tracked high is touched AND close >= level AND volume ratio <= capitulation threshold AND NOT (volume ratio >= absorption threshold AND body ratio > 0.6)
Short: A tracked low is touched AND close <= level AND ((volume ratio >= absorption threshold AND body ratio > 0.6) OR (volume ratio > capitulation threshold AND NOT (volume ratio >= absorption threshold AND body ratio > 0.6)))