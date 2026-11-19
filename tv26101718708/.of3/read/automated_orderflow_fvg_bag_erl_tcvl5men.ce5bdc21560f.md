Calculation: Bullish FVG on timeframe T = low of the current T bar > high of the second previous T bar
Calculation: Bearish FVG on timeframe T = high of the current T bar < low of the second previous T bar
Calculation: Latest chart bullish FVG zone = from high[2] (bottom) to low (top) on the most recent chart bar where low > high[2]; latest chart bearish FVG zone = from high (bottom) to low[2] (top) on the most recent chart bar where high < low[2]
Calculation: Chart direction starts neutral; when FVG zones are enabled, a bullish chart FVG sets it bullish and a bearish chart FVG sets it bearish; on later chart bars, a close below the latest bullish zone bottom sets it bearish and a close above the latest bearish zone top sets it bullish, with the latter taking precedence; otherwise it retains its prior value
Calculation: T1 direction starts neutral; when the T1 filter is enabled, on chart bars that start a new T1 bar, set it bullish if the still-forming T1 bar has a bullish FVG or bearish if it has a bearish FVG; evaluate each FVG on T1 bars and otherwise retain the prior direction
Calculation: Effective direction = T1 direction when the T1 filter is enabled and that direction is nonneutral; otherwise chart direction
Long: Effective direction is bullish
Short: Effective direction is bearish
Long: Bullish FVG on a chart bar AND effective direction is bullish
Short: Bearish FVG on a chart bar AND effective direction is bearish
Long: On any later chart bar, close > top of the latest bearish FVG zone
Short: On any later chart bar, close < bottom of the latest bullish FVG zone
Long: BAG marking is enabled AND this is the first later chart bar where low <= top of the latest bullish FVG zone AND close > bottom of that zone
Short: BAG marking is enabled AND this is the first later chart bar where high >= bottom of the latest bearish FVG zone AND close < top of that zone