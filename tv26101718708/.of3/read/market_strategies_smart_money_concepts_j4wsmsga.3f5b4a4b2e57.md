Calculation: Structural state = confirmed PivotHigh(high, swing lookback, swing lookback) and PivotLow(low, swing lookback, swing lookback) levels; trend reverses when close reaches the protected opposite level; a continuation level is set at the trend extreme after price exceeds the opposite running extreme and two consecutive candles have bodies in the opposite direction; in adjusted-points mode, protected levels update from later confirmed pivots
Calculation: Order block boundaries come from the source candle selected by the structural swing search at a BOS or CHoCH; for a bullish block, bottom = source low and top = min(source high, source low + ATR(ATR lookback)) or source high under full-candle construction; for a bearish block, top = source high and bottom = max(source low, source high - ATR(ATR lookback)) or source low under full-candle construction; a bullish block is mitigated when min(close, open) < bottom, low < bottom, or low < midpoint, according to the mitigation method; a bearish block is mitigated when max(close, open) > top, high > top, or high > midpoint, according to the mitigation method
Long: Bearish structural trend AND close >= protected structural high
Short: Bullish structural trend AND close <= protected structural low
Long: Bullish structural trend AND close >= active bullish continuation level
Short: Bearish structural trend AND close <= active bearish continuation level
Long: Bullish structural trend
Short: Bearish structural trend
Long: First bar since creation of the latest unmitigated bullish order block on which low < its top
Short: First bar since creation of the latest unmitigated bearish order block on which high > its bottom