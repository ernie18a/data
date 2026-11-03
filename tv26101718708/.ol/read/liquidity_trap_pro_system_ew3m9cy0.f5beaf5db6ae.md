Calculation: candle body = abs(close - open)
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: HTF-A high/low = high/low of a higher-timeframe bar still forming
Calculation: HTF-B high/low = high/low of another higher-timeframe bar still forming
Long: (low < HTF-A low OR low < HTF-B low) AND the previous three candles each closed below their open AND close > open AND (lower wick > candle body OR candle body > 1.5 × upper wick) AND close - open > ATR × displacement multiplier AND HTF-A low - low > minimum sweep depth
Short: (high > HTF-A high OR high > HTF-B high) AND the previous three candles each closed above their open AND close < open AND (upper wick > candle body OR candle body > 1.5 × lower wick) AND open - close > ATR × displacement multiplier AND high - HTF-A high > minimum sweep depth