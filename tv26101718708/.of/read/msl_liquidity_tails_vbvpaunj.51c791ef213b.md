Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: candle body = max(abs(close - open), minimum price increment)
Long: On a completed chart bar, lower wick >= ATR × ATR multiplier AND lower wick >= candle body × wick/body multiplier AND lower wick > upper wick × wick dominance multiplier AND current bar index - last signal bar > minimum gap
Short: On a completed chart bar, upper wick >= ATR × ATR multiplier AND upper wick >= candle body × wick/body multiplier AND upper wick > lower wick × wick dominance multiplier AND current bar index - last signal bar > minimum gap