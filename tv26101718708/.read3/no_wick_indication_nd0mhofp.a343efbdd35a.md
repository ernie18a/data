Calculation: candle body size = abs(close - open)
Calculation: volume filter = previous-volume filter disabled OR volume > volume[1]
Long: close > open AND candle body size >= minimum body size parameter AND (abs(high - close) <= wick tolerance parameter OR abs(open - low) <= wick tolerance parameter) AND volume filter
Short: close < open AND candle body size >= minimum body size parameter AND (abs(high - open) <= wick tolerance parameter OR abs(close - low) <= wick tolerance parameter) AND volume filter