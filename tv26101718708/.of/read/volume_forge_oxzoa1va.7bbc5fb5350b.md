Calculation: Delta oscillator = EMA of 100 times the rolling sum of directional volume divided by the rolling sum of volume; directional volume is volume * (close - open) / (high - low), or zero when high equals low. Use zero when the rolling volume sum is zero; initialize both rolling sums with zero-filled windows.
Calculation: Relative volume = volume / SMA(volume).
Calculation: Wave direction = initially down with extreme equal to the first close; while up, update the extreme to a higher close, otherwise switch down and reset the extreme to close when close <= extreme - ATR * multiplier; while down, update the extreme to a lower close, otherwise switch up and reset the extreme to close when close >= extreme + ATR * multiplier.
Calculation: Directional scores = sum separate configurable weights for each satisfied condition, using corresponding weights for both sides: delta oscillator > 0 / < 0; delta oscillator > / < its previous value; relative volume >= its threshold AND close >= / < open; CMF > positive threshold / < negative threshold; CMF > / < its previous value; wave direction = up / down. A side has a vote when at least one of its conditions is satisfied, even if its weight is zero.
Calculation: Normalized efficiency = percentile rank of abs(close - open) / volume over its lookback, divided by 100; use zero efficiency when volume <= 0.
Long: Delta oscillator >= 0.
Short: Delta oscillator < 0.
Long: Close >= open.
Short: Close < open.
Long: CMF > 0.
Short: CMF < 0.
Long: Wave direction = up.
Short: Wave direction = down.
Long: Delta oscillator > its previous value.
Short: Delta oscillator < its previous value.
Long: CMF > its previous value.
Short: CMF < its previous value.
Long: Bullish directional score > bearish directional score.
Short: Bearish directional score > bullish directional score.
Long: At least one directional vote exists AND (close > open OR (close = open AND bullish directional score >= bearish directional score)).
Short: At least one directional vote exists AND (close < open OR (close = open AND bearish directional score > bullish directional score)).
Long: Relative volume > absorption threshold AND normalized efficiency < efficiency threshold AND high - low < ATR using the efficiency lookback * range multiplier AND close < open.
Short: Relative volume > absorption threshold AND normalized efficiency < efficiency threshold AND high - low < ATR using the efficiency lookback * range multiplier AND close >= open.
Long: A delta oscillator pivot low is confirmed using equal left and right pivot lengths AND its oscillator value > the preceding confirmed oscillator pivot low value AND the low at the current pivot < the low at the preceding pivot AND the number of bars since the preceding pivot confirmation, measured from the previous bar, is between the minimum and maximum separation inclusive.
Short: A delta oscillator pivot high is confirmed using equal left and right pivot lengths AND its oscillator value < the preceding confirmed oscillator pivot high value AND the high at the current pivot > the high at the preceding pivot AND the number of bars since the preceding pivot confirmation, measured from the previous bar, is between the minimum and maximum separation inclusive.
Long: Close > open AND at least one directional vote exists AND bullish directional score >= signal threshold AND (first-occurrence filtering is disabled OR the preceding bar did not satisfy these conditions).
Short: Close < open AND at least one directional vote exists AND bearish directional score >= signal threshold AND (first-occurrence filtering is disabled OR the preceding bar did not satisfy these conditions).