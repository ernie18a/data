Calculation: sell-side pool = low of a completed Asia or London session, low of the last completed T1 bar, low of the last completed T2 bar, or the lower of two consecutive pivot lows (pivot length each side) whose difference is at most equal-level tolerance * ATR(ATR length); created no more than pool max age ago
Calculation: buy-side pool = high of a completed Asia or London session, high of the last completed T1 bar, high of the last completed T2 bar, or the higher of two consecutive pivot highs (pivot length each side) whose difference is at most equal-level tolerance * ATR(ATR length); created no more than pool max age ago
Calculation: sell-side raid = for some sell-side pool level L: close > L AND low < L on some bar within the last reclaim window bars including current bar AND L not already raided or taken
Calculation: buy-side raid = for some buy-side pool level H: close < H AND high > H on some bar within the last reclaim window bars including current bar AND H not already raided or taken
Calculation: long MSS reference = min(last pivot high confirmed by the sell-side raid bar, highest high of the MSS lookback bars before that raid bar)
Calculation: short MSS reference = max(last pivot low confirmed by the buy-side raid bar, lowest low of the MSS lookback bars before that raid bar)
Calculation: bullish MSS = a bar within MSS window bars after a sell-side raid where close > long MSS reference AND close > open AND abs(close - open) >= ATR(ATR length) * displacement multiple
Calculation: bearish MSS = a bar within MSS window bars after a buy-side raid where close < short MSS reference AND close < open AND abs(close - open) >= ATR(ATR length) * displacement multiple
Calculation: bullish FVG = low > high[2] AND low - high[2] >= min FVG size
Calculation: bearish FVG = high < low[2] AND low[2] - high >= min FVG size
Calculation: long entry level = top - entry fraction * (top - bottom), where top = low and bottom = high[2] of the latest bullish FVG whose first candle is at or after the sell-side raid bar
Calculation: short entry level = bottom + entry fraction * (top - bottom), where top = low[2] and bottom = high of the latest bearish FVG whose first candle is at or after the buy-side raid bar
Calculation: long stop = lowest low from the first bar trading through the raided sell-side pool through the long order bar - stop buffer
Calculation: short stop = highest high from the first bar trading through the raided buy-side pool through the short order bar + stop buffer
Calculation: long target = if target mode is fixed R, long entry level + fixed R * (long entry level - long stop); otherwise the lowest buy-side pool level above long entry level, not already raided or taken at the long order bar, with (level - long entry level) >= min R * (long entry level - long stop) if one exists, else long entry level + fixed R * (long entry level - long stop)
Calculation: short target = if target mode is fixed R, short entry level - fixed R * (short stop - short entry level); otherwise the highest sell-side pool level below short entry level, not already raided or taken at the short order bar, with (short entry level - level) >= min R * (short stop - short entry level) if one exists, else short entry level - fixed R * (short stop - short entry level)
Calculation: bias ok long = bias filter disabled OR close(T3, last completed bar) > EMA(close, bias EMA length, T3, last completed bar)
Calculation: bias ok short = bias filter disabled OR close(T3, last completed bar) <= EMA(close, bias EMA length, T3, last completed bar)
Calculation: long order = a bar where long entry level exists AND long entry level > long stop AND a bullish MSS occurred on this bar or within MSS-to-FVG window bars before it AND position side flat AND trades filled in current NY session < max trades per day AND, after a sell-side raid in NY session with bias ok long on the raid bar, all bars from that raid through this bar are in NY session
Calculation: short order = a bar where short entry level exists AND short entry level < short stop AND a bearish MSS occurred on this bar or within MSS-to-FVG window bars before it AND position side flat AND trades filled in current NY session < max trades per day AND, after a buy-side raid in NY session with bias ok short on the raid bar, all bars from that raid through this bar are in NY session
Long: low <= long entry level AND 1 <= bars since long order <= fill expiry AND close >= long stop on every bar from long order through the bar before current AND position side flat on every bar from long order through current bar AND bar in NY session on every bar from long order through the bar before current
Short: high >= short entry level AND 1 <= bars since short order <= fill expiry AND close <= short stop on every bar from short order through the bar before current AND position side flat on every bar from short order through current bar AND bar in NY session on every bar from short order through the bar before current
Exit: Long, bar after entry AND low <= long stop
Exit: Long, bar after entry AND high >= long target
Exit: Long, bar after entry AND bar in flatten session
Exit: Short, bar after entry AND high >= short stop
Exit: Short, bar after entry AND low <= short target
Exit: Short, bar after entry AND bar in flatten session