Calculation: Alternating pivots = confirmed pivot highs and lows of the selected source using the same pivot lookback on both sides, ordered by pivot bar, with a same-type last pivot replaced only by a more extreme pivot
Calculation: Resistance trendline = line through the two most recent confirmed pivot highs
Calculation: Support trendline = line through the two most recent confirmed pivot lows
Calculation: Touch count(line) = bars within the touch lookback where the selected resistance high or support low source in wick mode, or close in close mode, is within touch tolerance of the line, counting touches only when separated by at least the minimum spacing
Calculation: Breakout arm = set whenever resistance and support touch counts each meet the minimum touch count, cleared by either breakout
Calculation: Pending long breakout = set by a long breakout, cleared by a long retest or short breakout, and expires after the breakout wait
Calculation: Pending short breakout = set by a short breakout, cleared by a short retest or long breakout, and expires after the breakout wait
Calculation: Head-and-shoulders neckline = line through the second and fourth pivots of a five-pivot head-and-shoulders pattern, extended forward
Calculation: Double-pattern neckline = horizontal line through the middle pivot of a three-pivot double top or double bottom
Long: Breakout arm active AND close crosses above Resistance trendline + break confirmation
Short: Breakout arm active AND close crosses below Support trendline - break confirmation
Long: Pending long breakout AND low <= Resistance trendline + retest tolerance AND close > Resistance trendline AND (EMA filter disabled OR EMA(close, shorter lookback) > EMA(close, longer lookback) OR close > EMA(close, longer lookback))
Short: Pending short breakout AND high >= Support trendline - retest tolerance AND close < Support trendline AND (EMA filter disabled OR EMA(close, shorter lookback) < EMA(close, longer lookback) OR close < EMA(close, longer lookback))
Long: Pending long breakout AND watch dots enabled
Short: Pending short breakout AND watch dots enabled
Long: A new inverse head-and-shoulders setup is detected when the latest five alternating pivots are low-high-low-high-low, the first and fifth lows differ by at most pattern tolerance, the middle low is below each shoulder by more than pattern tolerance, and the first-to-fifth span is at least the minimum pattern span; inverse head-and-shoulders detector and pattern watch labels enabled
Short: A new head-and-shoulders setup is detected when the latest five alternating pivots are high-low-high-low-high, the first and fifth highs differ by at most pattern tolerance, the middle high is above each shoulder by more than pattern tolerance, and the first-to-fifth span is at least the minimum pattern span; head-and-shoulders detector and pattern watch labels enabled
Long: A new double-bottom setup is detected when the latest three alternating pivots are low-high-low, the first and third lows differ by at most pattern tolerance, and the first-to-third span is at least the minimum pattern span; double-bottom detector and pattern watch labels enabled
Short: A new double-top setup is detected when the latest three alternating pivots are high-low-high, the first and third highs differ by at most pattern tolerance, and the first-to-third span is at least the minimum pattern span; double-top detector and pattern watch labels enabled
Long: Active inverse head-and-shoulders setup before its wait expires AND close > Head-and-shoulders neckline + neckline break buffer AND pattern detection and inverse head-and-shoulders detector enabled
Short: Active head-and-shoulders setup before its wait expires AND close < Head-and-shoulders neckline - neckline break buffer AND pattern detection and head-and-shoulders detector enabled
Long: Active double-bottom setup before its wait expires AND close > Double-pattern neckline + neckline break buffer AND pattern detection and double-bottom detector enabled
Short: Active double-top setup before its wait expires AND close < Double-pattern neckline - neckline break buffer AND pattern detection and double-top detector enabled