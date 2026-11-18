Calculation: AVWAP_earnings = volume-weighted average of (high+low+close)/3 from the earnings-event anchor bar through the current bar
Calculation: AVWAP_swing_low = volume-weighted average of (high+low+close)/3 from the swing-low anchor bar through the current bar
Long: close > AVWAP_earnings AND close > AVWAP_swing_low
Short: close < AVWAP_earnings AND close < AVWAP_swing_low