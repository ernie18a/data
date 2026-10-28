Calculation: candle body = abs(close - open)
Calculation: upper shadow = high - max(close, open)
Calculation: lower shadow = min(close, open) - low
Long: close < SMA(close) AND volume > SMA(volume) AND ((open < previous bar close AND close > previous bar open AND candle body > previous bar candle body) OR (lower shadow > 2 * candle body AND upper shadow < candle body) OR (upper shadow > 2 * candle body AND lower shadow < candle body))
Short: close > SMA(close) AND volume > SMA(volume) AND ((open > previous bar close AND close < previous bar open AND candle body > previous bar candle body) OR (upper shadow > 2 * candle body AND lower shadow < candle body) OR (lower shadow > 2 * candle body AND upper shadow < candle body))