Calculation: Volume-normalized candle body = ((close - open) / volume) * 1,000,000,000
Calculation: Average volume-normalized candle body = simple moving average of the volume-normalized candle body over a lookback period
Long: Volume-normalized candle body >= Average volume-normalized candle body * multiplier AND close > open
Short: Volume-normalized candle body >= Average volume-normalized candle body * multiplier AND close < open