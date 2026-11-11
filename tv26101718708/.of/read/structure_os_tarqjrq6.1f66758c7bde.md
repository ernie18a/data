Calculation: Swing high = track the highest high since the last high confirmation, replacing it and resetting its count whenever high is greater than or equal to it. Otherwise increment the count when close < open AND close < previous bar's low; leave the count unchanged on other bars. When the count reaches a confirmation threshold, set the swing high to the tracked high and restart tracking. A close above the swing high removes that swing high.
Calculation: Swing low = track the lowest low since the last low confirmation, replacing it and resetting its count whenever low is less than or equal to it. Otherwise increment the count when close > open AND close > previous bar's high; leave the count unchanged on other bars. Use the same confirmation threshold as for the swing high. When the count reaches the threshold, set the swing low to the tracked low and restart tracking. A close below the swing low removes that swing low.
Calculation: Swing direction = initially bullish; set it to bullish when close > swing high, otherwise set it to bearish when close < swing low. Preserve it on other bars. Evaluate breaks after updating confirmed swing levels; an upward break takes precedence over a downward break.
Calculation: Internal high = while both swing levels exist, independently track highs and count qualifying bearish bars using the swing-high tracking rules. When the count equals the swing confirmation threshold AND the tracked high is strictly between the swing levels, set the internal high to that tracked high and restart its tracker. A swing break resets the internal tracker and removes the internal high; a close above the internal high removes it. If the count reaches the threshold outside the swing range, continue tracking without resetting the count.
Long: A newly confirmed swing high differs from the previously confirmed swing high.
Short: A newly confirmed swing low differs from the previously confirmed swing low.
Long: Close > swing high.
Short: Close < swing low AND close is not above the swing high.
Long: A new internal high is confirmed.
Long: Both swing levels exist AND close > internal high.
Long: Swing direction = bullish.
Short: Swing direction = bearish.
Long: On each of two higher timeframes, the still-forming bar's close > the last completed bar's high.
Short: On each of two higher timeframes, the still-forming bar's close < the last completed bar's low.
Short: On each of two higher timeframes, the still-forming bar's close is between the last completed bar's low and high inclusive AND chart-bar high > that completed high AND the still-forming close < that completed high.
Long: On each of two higher timeframes, the still-forming bar's close is between the last completed bar's low and high inclusive AND the bearish sweep condition is false AND chart-bar low < that completed low AND the still-forming close > that completed low.
Long: On each of several higher timeframes, the still-forming bar's close > the last completed bar's close.
Short: On each of several higher timeframes, the still-forming bar's close <= the last completed bar's close.