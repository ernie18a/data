Calculation: Moving-average alignment = +1 if close > shortest MA > each successively longer MA through the longest; −1 if close < shortest MA < each successively longer MA through the longest; otherwise, when partial alignment is included, +0.5 if more than five of those seven comparisons are upward, −0.5 if fewer than two are upward, +0.25 if more than three are upward, else −0.25; otherwise 0. The moving averages use progressively longer lookbacks.
Calculation: Alignment index = rolling sum of moving-average alignment.
Calculation: High-low index = +1 if the current high is the highest high in its lookback; otherwise −1 if the current low is the lowest low in its lookback; otherwise 0.
Calculation: Cumulative high-low index = rolling sum of high-low index.
Calculation: Index direction = +1 when the index is greater than its previous value, −1 when less, otherwise its previous nonzero direction.
Calculation: Annual high condition = the author’s annual high filter: using highs from the last completed bars of a higher timeframe, allow entry when the latest annual high exceeds the referenced prior annual highs, or close exceeds the author’s threshold formed from those highs; missing referenced highs make the corresponding test pass.
Calculation: Annual low condition = the corresponding annual low filter using lows from the last completed bars of a higher timeframe; allow entry when the latest annual low is below the referenced prior annual lows, or close is below the author’s threshold formed from those lows; missing referenced lows make the corresponding test pass.
Long: Supertrend direction = −1 AND alignment index direction = +1 AND cumulative high-low index direction = +1 AND annual high condition
Short: Supertrend direction = +1 AND alignment index direction = −1 AND cumulative high-low index direction = −1 AND annual low condition
Exit: Long, Supertrend direction = +1
Exit: Short, Supertrend direction = −1