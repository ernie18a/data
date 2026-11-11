Long: Close > shortest-period SMA of close
Short: Close <= shortest-period SMA of close
Long: Medium-period SMA of close > its previous value
Short: Medium-period SMA of close <= its previous value
Long: Medium-period SMA of close > longest-period SMA of close AND abs(close - longest-period SMA of close) / longest-period SMA of close >= distance threshold
Short: Medium-period SMA of close < longest-period SMA of close AND abs(close - longest-period SMA of close) / longest-period SMA of close >= distance threshold
Long: High - low > ATR multiplied by a threshold AND high - low > 0 AND abs(close - open) / (high - low) > body-ratio threshold AND close > open
Short: High - low > ATR multiplied by a threshold AND high - low > 0 AND abs(close - open) / (high - low) > body-ratio threshold AND close < open
Long: Low > high two bars ago
Short: High < low two bars ago
Long: Close crosses above an EMA calculated on a higher timeframe, using the last completed higher-timeframe bar on historical bars and the forming bar in real time
Short: Close crosses below an EMA calculated on a higher timeframe, using the last completed higher-timeframe bar on historical bars and the forming bar in real time