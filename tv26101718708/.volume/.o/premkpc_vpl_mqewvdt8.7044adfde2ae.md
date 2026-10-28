Long: hlc3 >= EMA(close, shorter lookback)
Long: hlc3 >= EMA(close, longer lookback)
Short: hlc3 < EMA(close, shorter lookback)
Short: hlc3 < EMA(close, longer lookback)
Calculation: PUT and CALL volume-profile levels = Over their respective rolling lookbacks of current-timeframe bars, divide the highest-high to lowest-low range into equal bins and distribute each bar’s volume across bins in proportion to the overlap with its high-low range. The PUT lookback is longer than the CALL lookback. The point of control is the bin with the greatest volume; expand the value area from that bin, adding the higher-volume adjacent bin until the configured share of total volume is reached. VAH is the upper edge and VAL the lower edge of that area. Include the current bar, which may still be forming.
Exit: Long, high >= CALL VAH OR low <= PUT VAL
Exit: Short, high >= PUT VAH OR low <= CALL VAL