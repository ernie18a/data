Calculation: RTH VWAP = VWAP(hlc3, volume, since RTH open)
Calculation: overnight VWAP = VWAP(hlc3, volume, since overnight-session open)
Calculation: opening-range high = high of the T1 bar at the RTH open, evaluated on chart bars using the still-forming T1 bar
Calculation: opening-range low = low of the T1 bar at the RTH open, evaluated on chart bars using the still-forming T1 bar
Calculation: Long reclaim = the selected successive-close rule, requiring current and previous RTH closes above RTH VWAP, or the selected single-close-plus-hold rule, requiring current RTH close above RTH VWAP and (previous RTH close above previous RTH VWAP or previous close at or below previous RTH VWAP)
Calculation: Short reclaim = the selected successive-close rule, requiring current and previous RTH closes below RTH VWAP, or the selected single-close-plus-hold rule, requiring current RTH close below RTH VWAP and (previous RTH close below previous RTH VWAP or previous close at or above previous RTH VWAP)
Calculation: Reclaimed-long state = reset at RTH open or after current and previous RTH closes below RTH VWAP; set on Long reclaim
Calculation: Reclaimed-short state = reset at RTH open or after current and previous RTH closes above RTH VWAP; set on Short reclaim
Calculation: Upward price/RTH-VWAP cross = the selected close crossover of close above RTH VWAP, or the selected wick cross with low at or below RTH VWAP, high at or above RTH VWAP, previous close below previous RTH VWAP, and current close above RTH VWAP
Calculation: Downward price/RTH-VWAP cross = the selected close crossunder of close below RTH VWAP, or the selected wick cross with high at or above RTH VWAP, low at or below RTH VWAP, previous close above previous RTH VWAP, and current close below RTH VWAP
Long: EMA(close, fast lookback) crosses above EMA(close, slow lookback) during RTH of the latest or preceding trade session
Short: EMA(close, fast lookback) crosses below EMA(close, slow lookback) during RTH of the latest or preceding trade session
Long: Upward price/RTH-VWAP cross during RTH of the latest or preceding trade session, excluding the first RTH bar
Short: Downward price/RTH-VWAP cross during RTH of the latest or preceding trade session, excluding the first RTH bar
Long: RTH VWAP crosses above overnight VWAP during RTH of the latest or preceding trade session, excluding the first RTH bar
Short: RTH VWAP crosses below overnight VWAP during RTH of the latest or preceding trade session, excluding the first RTH bar
Long: During the configured trade window and latest or preceding trade session, Reclaimed-long state is true, EMA(close, fast lookback) > EMA(close, middle lookback) > EMA(close, slow lookback), each EMA is above its previous value, low <= RTH VWAP + touch buffer, close > RTH VWAP, and (volume > previous volume if rising-volume confirmation is enabled)
Short: During the configured trade window and latest or preceding trade session, Reclaimed-short state is true, EMA(close, fast lookback) < EMA(close, middle lookback) < EMA(close, slow lookback), each EMA is below its previous value, high >= RTH VWAP - touch buffer, close < RTH VWAP, and (volume > previous volume if rising-volume confirmation is enabled)
Long: After a qualifying long hold, enter at the latest qualifying hold candle high + entry offset when price reaches that level while flat, during the configured trade window and latest or preceding trade session, the number of upward and downward price/RTH-VWAP crosses in the current RTH session is below its maximum, and round(((setup high + entry offset) - (setup low - stop buffer)) / tick size) is within the maximum stop distance and positive; replace the setup with each later qualifying long hold and invalidate it when the reclaimed-long state or EMA trend fails, the acceptance condition below VWAP occurs, the trade window or session eligibility ends, or the cross-count limit is reached
Short: After a qualifying short hold, enter at the latest qualifying hold candle low - entry offset when price reaches that level while flat, during the configured trade window and latest or preceding trade session, the number of upward and downward price/RTH-VWAP crosses in the current RTH session is below its maximum, and round(((setup high + stop buffer) - (setup low - entry offset)) / tick size) is within the maximum stop distance and positive; replace the setup with each later qualifying short hold and invalidate it when the reclaimed-short state or EMA trend fails, the acceptance condition above VWAP occurs, the trade window or session eligibility ends, or the cross-count limit is reached
Exit: Long, low <= setup low - stop buffer OR high >= entry price + profit target distance
Exit: Short, high >= setup high + stop buffer OR low <= entry price - profit target distance
Long: Each displayed external instrument close > its RTH VWAP
Short: Each displayed external instrument close < its RTH VWAP
Long: Each displayed external instrument close > its overnight VWAP
Short: Each displayed external instrument close < its overnight VWAP
Long: Each displayed external instrument close > its previous completed RTH VWAP
Short: Each displayed external instrument close < its previous completed RTH VWAP
Long: Each external instrument with an opening-range status row has close > its opening-range high
Short: Each external instrument with an opening-range status row has close < its opening-range low