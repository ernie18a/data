Calculation: candle range = NormalizeDouble((high - low) / point size, price decimal precision)
Calculation: candle body = NormalizeDouble(abs(open - close) / point size, price decimal precision)
Long: close[1] > open[1] AND close[2] > open[2] AND candle range[1] > candle range[2] AND candle body[1] >= candle body[2]
Short: close[1] < open[1] AND close[2] < open[2] AND candle body[1] > candle body[2] AND candle range[1] >= candle range[2]