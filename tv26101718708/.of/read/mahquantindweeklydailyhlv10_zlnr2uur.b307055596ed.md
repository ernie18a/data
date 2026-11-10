Long: close > open AND previous close < previous open AND close - low > previous high - previous close
Short: close < open AND previous close > previous open AND high - close > previous close - previous low
Long: close > open AND (volume < SMA(volume) OR (abs(close - open) / abs(high - low) > body-ratio threshold AND volume > SMA(volume)))
Short: NOT (close > open AND (volume < SMA(volume) OR (abs(close - open) / abs(high - low) > body-ratio threshold AND volume > SMA(volume))))