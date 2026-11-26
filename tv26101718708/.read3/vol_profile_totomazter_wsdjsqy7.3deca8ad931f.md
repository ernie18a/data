Calculation: bullish volume share = if high > low then (close >= open ? 0.5 + abs(close - open) / (high - low) * 0.5 : 0.5 - abs(close - open) / (high - low) * 0.5) else 0.5
Long: volume * (1 - bullish volume share) = 0 OR bullish volume share > 0.5
Short: volume * (1 - bullish volume share) > 0 AND bullish volume share <= 0.5
Long: volume > 0 AND bullish volume share > 0.5
Short: volume <= 0 OR (volume > 0 AND bullish volume share <= 0.5)