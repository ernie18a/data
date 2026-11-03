Calculation: Bullish FVG = current low > high two bars ago
Calculation: Bearish FVG = current high < low two bars ago
Calculation: Bullish IFVG = a bearish FVG that has not previously been invalidated and current close > its upper boundary (the low from two bars ago)
Calculation: Bearish IFVG = a bullish FVG that has not previously been invalidated and current close < its lower boundary (the high from two bars ago)
Calculation: Bullish OB = an OB created when a bullish FVG forms, spanning the high and low from two bars ago, and not previously invalidated by a low below its lower boundary
Calculation: Bearish OB = an OB created when a bearish FVG forms, spanning the high and low from two bars ago, and not previously invalidated by a high above its upper boundary
Calculation: Pivot high/low = a high/low greater/less than the highs/lows in the specified number of bars on both sides; becomes known after the bars on its right complete
Long: any active Bullish OB OR Bullish IFVG OR current low < the latest confirmed pivot low AND current close > that pivot low OR current close >= open of the still-forming bar from the source's fixed higher timeframe
Short: any active Bearish OB OR Bearish IFVG OR current high > the latest confirmed pivot high AND current close < that pivot high OR current close < open of the still-forming bar from the source's fixed higher timeframe