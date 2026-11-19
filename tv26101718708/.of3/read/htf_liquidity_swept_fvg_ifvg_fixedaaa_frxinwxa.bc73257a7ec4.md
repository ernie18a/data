Calculation: Bullish FVG top = IF(FVG mode is body, min(open, close), low)
Calculation: Bullish FVG bottom = IF(FVG mode is body, max(open[2], close[2]), high[2])
Calculation: Bearish FVG top = IF(FVG mode is body, min(open[2], close[2]), low[2])
Calculation: Bearish FVG bottom = IF(FVG mode is body, max(open, close), high)
Long: FVG enabled AND bullish FVG top > bullish FVG bottom AND bullish FVG top - bullish FVG bottom >= minimum price points
Short: FVG enabled AND bearish FVG top > bearish FVG bottom AND bearish FVG top - bearish FVG bottom >= minimum price points
Long: FVG enabled AND a prior tracked, un-inverted bearish FVG exists AND close > its top
Short: FVG enabled AND a prior tracked, un-inverted bullish FVG exists AND close < its bottom