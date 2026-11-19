Calculation: Latest unbroken swing high = most recent confirmed PivotHigh(high, swing length, swing length), replaced by each newer confirmed pivot high and cleared after close exceeds it
Calculation: Latest unbroken swing low = most recent confirmed PivotLow(low, swing length, swing length), replaced by each newer confirmed pivot low and cleared after close falls below it
Calculation: Structure direction = direction of the most recent break of an unbroken swing high or low; undefined before the first break
Long: close > VWAP(hlc3) AND close > EMA(close, longer lookback) AND EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: close < VWAP(hlc3) AND close < EMA(close, longer lookback) AND EMA(close, shorter lookback) < EMA(close, longer lookback)
Long: close > latest unbroken swing high
Short: close < latest unbroken swing low
Long: structure direction is bullish
Short: structure direction is bearish
Long: low > high[n] AND low - high[n] >= minimum gap size
Short: high < low[n] AND low[n] - high >= minimum gap size