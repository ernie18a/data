Calculation: confirmed swing high/low = replace the high/low candidate and reset its count whenever high >= the high candidate or low <= the low candidate; otherwise accumulate qualifying bearish bars for highs (close < open AND close < low[1]) and bullish bars for lows (close > open AND close > high[1]); nonqualifying bars do not reset the count; confirm after the confirmation-count parameter is reached, store the candidate if it differs from the active level, then reset the candidate and count; a swing break clears the broken active level.
Calculation: confirmed internal high = track a high candidate and qualifying bearish-bar count using the confirmed swing-high rule while both active swing bounds exist; confirm and reset only when the count reaches the confirmation-count parameter and the candidate is strictly between the active swing low and high; a swing break resets the internal candidate, count, and level; an internal bullish break clears the internal high.
Calculation: swing bias = bullish initially; set bullish on a close above the active swing high and bearish on a close below the active swing low.
Long: chart close > active confirmed swing high
Short: chart close < active confirmed swing low
Long: chart close > active confirmed internal high
Long: swing bias is bullish
Short: swing bias is bearish
Long: for T1 or T2, close(T, current forming bar) > high(T, last completed bar) OR low(chart bar) < low(T, last completed bar) AND close(T, current forming bar) > low(T, last completed bar)
Short: for T1 or T2, close(T, current forming bar) < low(T, last completed bar) OR high(chart bar) > high(T, last completed bar) AND close(T, current forming bar) < high(T, last completed bar)
Long: on chart bars where T3 is higher than the chart timeframe, close(T3, current forming bar) > close(T3, last completed bar)
Short: on chart bars where T3 is higher than the chart timeframe, close(T3, current forming bar) <= close(T3, last completed bar)
Long: on chart bars where T4 is higher than the chart timeframe, close(T4, current forming bar) > close(T4, last completed bar)
Short: on chart bars where T4 is higher than the chart timeframe, close(T4, current forming bar) <= close(T4, last completed bar)
Long: on chart bars where T5 is higher than the chart timeframe, close(T5, current forming bar) > close(T5, last completed bar)
Short: on chart bars where T5 is higher than the chart timeframe, close(T5, current forming bar) <= close(T5, last completed bar)