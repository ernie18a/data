Long: PivotLow(low, swing lookback, swing lookback) is confirmed AND (no prior accepted pivot low OR abs(current pivot low - prior accepted pivot low) > ATR(dedup ATR lookback) * swing dedup tolerance)
Short: PivotHigh(high, swing lookback, swing lookback) is confirmed AND (no prior accepted pivot high OR abs(current pivot high - prior accepted pivot high) > ATR(dedup ATR lookback) * swing dedup tolerance)
Long: low > high[2] AND low - high[2] >= ATR(gap ATR lookback) * minimum gap size
Short: high < low[2] AND low[2] - high >= ATR(gap ATR lookback) * minimum gap size
Calculation: Retained FVG = a formed bullish gap whose close has not fallen below its lower boundary, or a formed bearish gap whose close has not risen above its upper boundary, and whose age is within the retention limit or age limiting is disabled
Calculation: Bullish-candle volume per FVG = sum of volume from the gap's formation through the current bar where close > open
Calculation: Bearish-candle volume per FVG = sum of volume from the gap's formation through the current bar where close < open
Long: Retained FVG AND bullish-candle volume per FVG > bearish-candle volume per FVG * dominance threshold
Short: Retained FVG AND bearish-candle volume per FVG > bullish-candle volume per FVG * dominance threshold