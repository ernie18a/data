Calculation: AVWAP = volume-weighted average of the selected source over the rolling lookback or, from a confirmed swing pivot, over bars since the selected swing low, swing high, or more recent of those pivots; use unit volume when volume is missing or nonpositive, and use the rolling calculation until a pivot anchor exists
Calculation: Weighted standard deviation = sqrt(max(volume-weighted average of selected-source squared over the AVWAP window minus AVWAP squared, 0)), using the same volume weights and window as AVWAP
Calculation: σ-distance = (close - AVWAP) / weighted standard deviation, or zero when the standard deviation is zero
Long: AVWAP is greater than or equal to its value on the previous bar
Short: AVWAP is less than its value on the previous bar
Long: lower outer-band rejection OR (no upper outer-band rejection AND AVWAP > AVWAP[slope lookback])
Short: upper outer-band rejection OR (no lower outer-band rejection AND AVWAP < AVWAP[slope lookback])
Long: close crosses above AVWAP
Short: close crosses below AVWAP
Long: low <= AVWAP - weighted standard deviation * outer-band multiplier AND close > AVWAP - weighted standard deviation * outer-band multiplier
Short: high >= AVWAP + weighted standard deviation * outer-band multiplier AND close < AVWAP + weighted standard deviation * outer-band multiplier
Long: close crosses above AVWAP + weighted standard deviation * outer-band multiplier
Short: close crosses below AVWAP - weighted standard deviation * outer-band multiplier
Long: a confirmed pivot low is lower than the prior confirmed pivot low AND σ-distance at that pivot is higher than at the prior pivot low
Short: a confirmed pivot high is higher than the prior confirmed pivot high AND σ-distance at that pivot is lower than at the prior pivot high
Calculation: T1 rolling VWAP and weighted standard deviation = volume-weighted average and standard deviation of the selected source over the rolling lookback, calculated on T1 bars using unit volume when volume is missing or nonpositive
Long: for each displayed higher timeframe T1, lower outer-band rejection OR (no upper outer-band rejection AND T1 rolling VWAP > T1 rolling VWAP[MTF slope lookback]); values run on T1 bars and map to chart bars with lookahead off (last completed T1 historically; forming T1 in realtime)
Short: for each displayed higher timeframe T1, upper outer-band rejection OR (no lower outer-band rejection AND T1 rolling VWAP <= T1 rolling VWAP[MTF slope lookback]); values run on T1 bars and map to chart bars with lookahead off (last completed T1 historically; forming T1 in realtime)