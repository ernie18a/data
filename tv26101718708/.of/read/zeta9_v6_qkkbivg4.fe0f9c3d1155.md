Calculation: Bullish fair value gap = the high two bars ago is below the current low
Calculation: Bearish fair value gap = the low two bars ago is above the current high
Calculation: Bullish order block = the previous candle closed below its open and the current close is above the previous high
Calculation: Bearish order block = the previous candle closed above its open and the current close is below the previous low
Calculation: Bullish pin bar = range > 0, lower wick ≥ 2/3 of range, and body ≤ 35% of range
Calculation: Bearish pin bar = range > 0, upper wick ≥ 2/3 of range, and body ≤ 35% of range
Long: flat position AND UTC hour is within a configured London or New York trading window AND close > long-term EMA AND short-term EMA > long-term EMA AND (VWAP filter disabled OR close > VWAP) AND RSI < overbought threshold AND (bullish fair value gap OR bullish order block OR previous bar is a bullish pin bar)
Short: flat position AND UTC hour is within a configured London or New York trading window AND close < long-term EMA AND short-term EMA < long-term EMA AND (VWAP filter disabled OR close < VWAP) AND RSI > oversold threshold AND (bearish fair value gap OR bearish order block OR previous bar is a bearish pin bar)
Long: bullish pin bar
Short: bearish pin bar
Exit: long position, bar low ≤ entry price − ATR × stop-loss multiple OR bar high ≥ entry price + ATR × take-profit multiple
Exit: short position, bar high ≥ entry price + ATR × stop-loss multiple OR bar low ≤ entry price − ATR × take-profit multiple