Calculation: Bull trend = EMA(close, fast EMA lookback) > EMA(close, mid EMA lookback) AND EMA(close, mid EMA lookback) > EMA(close, slow EMA lookback)
Calculation: Bear trend = EMA(close, fast EMA lookback) < EMA(close, mid EMA lookback) AND EMA(close, mid EMA lookback) < EMA(close, slow EMA lookback)
Long: EMA(close, fast EMA lookback) crosses above EMA(close, mid EMA lookback) AND close > EMA(close, slow EMA lookback) AND RSI(close, RSI lookback) < upper RSI threshold
Short: EMA(close, fast EMA lookback) crosses below EMA(close, mid EMA lookback) AND close < EMA(close, slow EMA lookback) AND RSI(close, RSI lookback) > lower RSI threshold
Long: Bull trend
Short: NOT Bull trend
Long: Bear trend[1] AND Bull trend
Short: Bull trend[1] AND Bear trend
Long: close > latest confirmed Pivot High(high, structure lookback, structure lookback) AND close[1] <= that same pivot high AND at least two such pivots have been confirmed
Short: close < latest confirmed Pivot Low(low, structure lookback, structure lookback) AND close[1] >= that same pivot low AND at least two such pivots have been confirmed
Short: Pivot High(high, zone pivot lookback, zone pivot lookback) is not na
Long: Pivot Low(low, zone pivot lookback, zone pivot lookback) is not na
Long: volume > SMA(volume, volume lookback) * volume surge multiplier AND close >= open
Short: volume > SMA(volume, volume lookback) * volume surge multiplier AND close < open
Short: Pivot High(RSI(close, RSI lookback), divergence pivot lookback, divergence pivot lookback) is not na AND Pivot High(high, divergence pivot lookback, divergence pivot lookback) is not na AND Pivot High(high, divergence pivot lookback, divergence pivot lookback) > its value 1 bar ago AND Pivot High(RSI(close, RSI lookback), divergence pivot lookback, divergence pivot lookback) < its value 1 bar ago
Long: Pivot Low(RSI(close, RSI lookback), divergence pivot lookback, divergence pivot lookback) is not na AND Pivot Low(low, divergence pivot lookback, divergence pivot lookback) is not na AND Pivot Low(low, divergence pivot lookback, divergence pivot lookback) < its value 1 bar ago AND Pivot Low(RSI(close, RSI lookback), divergence pivot lookback, divergence pivot lookback) > its value 1 bar ago
Long: A confirmed Pivot High(high, swing pivot lookback, swing pivot lookback) exists and is higher than the previous confirmed pivot high
Short: A confirmed Pivot High(high, swing pivot lookback, swing pivot lookback) exists and is lower than the previous confirmed pivot high
Short: A confirmed Pivot Low(low, swing pivot lookback, swing pivot lookback) exists and is lower than the previous confirmed pivot low
Long: A confirmed Pivot Low(low, swing pivot lookback, swing pivot lookback) exists and is higher than the previous confirmed pivot low
Long: MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) crosses above its signal line
Short: MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) crosses below its signal line