Calculation: gap side = bullish if low > high[2] at the gap formation bar, bearish if high < low[2] at the gap formation bar
Calculation: gap midpoint = (gap top + gap bottom) / 2 at the gap formation bar, where for a bullish gap gap top = low and gap bottom = high[2], and for a bearish gap gap top = low[2] and gap bottom = high
Calculation: flipped = on some bar since formation where the gap was not deleted on an earlier bar AND (close < gap bottom for a bullish gap OR close > gap top for a bearish gap)
Calculation: deleted = on some bar since formation, either (not flipped before that bar AND low <= gap midpoint AND high >= gap midpoint on that bar or an earlier bar since formation AND (close > gap top for a bullish gap OR close < gap bottom for a bearish gap)) OR (flipped before that bar AND (close > gap top OR close < gap bottom))
Calculation: TDO = open of the most recent bar starting at the TDO session start time
Calculation: window filter = gap formed in the window immediately before the current window AND NOT ((window midpoint < reference level AND gap midpoint > window open) OR (window midpoint > reference level AND gap midpoint < window open)), where window midpoint = (high + low) / 2 and window open = open of the gap's formation window, and where windows of length M1 aligned to midnight use reference level TDO on chart T1, windows of length M2 aligned to midnight use reference level TDO on chart T2, and windows of length M3 aligned to start time S3 use reference level = open of the most recent bar starting at the TWO session start time on the TWO weekday as of gap formation on chart T3
Calculation: visible = (bars since formation + 2) <= lookback AND (window mode off for the current chart OR window filter)
Calculation: long gap = (gap side is bullish AND NOT flipped) OR (gap side is bearish AND flipped)
Calculation: short gap = (gap side is bearish AND NOT flipped) OR (gap side is bullish AND flipped)
Long: long gap AND NOT deleted AND visible
Short: short gap AND NOT deleted AND visible
Calculation: long stop = low[1] at the gap formation bar
Calculation: short stop = high[1] at the gap formation bar
Exit: long, low <= long stop OR high >= entry price + R * (entry price - long stop)
Exit: short, high >= short stop OR low <= entry price - R * (short stop - entry price)