Calculation: RelVolume = volume / SMA(volume, lookback)[1]
Calculation: UpSide = IF volume-based colouring AND T1 bars inside the last completed bar have total volume above zero THEN (volume of T1 bars inside the last completed bar with close > open) >= (volume of T1 bars inside the last completed bar with close < open) ELSE close >= (high + low) / 2
Calculation: BubblePrice = IF volume-based position AND T1 bars inside the last completed bar have total volume above zero THEN (high + low + close) / 3 of the T1 bar with the largest volume among the T1 bars inside the last completed bar ELSE (high + low + close) / 3 of the last completed bar
Calculation: LastDownLevel = IF RelVolume >= heavy threshold AND NOT UpSide THEN BubblePrice ELSE LastDownLevel[1]
Calculation: LastUpLevel = IF RelVolume >= heavy threshold AND UpSide THEN BubblePrice ELSE LastUpLevel[1]
Long: (RelVolume >= heavy threshold OR (RelVolume >= small threshold AND small bubbles shown)) AND UpSide
Short: (RelVolume >= heavy threshold OR (RelVolume >= small threshold AND small bubbles shown)) AND NOT UpSide
Long: close > LastDownLevel[1] AND close[1] <= LastDownLevel[1]
Short: close < LastUpLevel[1] AND close[1] >= LastUpLevel[1]