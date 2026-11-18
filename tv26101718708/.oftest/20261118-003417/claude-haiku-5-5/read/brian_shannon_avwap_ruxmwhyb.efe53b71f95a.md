Calculation: AVWAP_EARNINGS = AVWAP(HLC3, volume, anchor = most recent earnings bar)
Calculation: AVWAP_SWING_LOW = AVWAP(HLC3, volume, anchor = most recent swing low bar)
Long: close > AVWAP_EARNINGS AND close > AVWAP_SWING_LOW
Short: close < AVWAP_EARNINGS AND close < AVWAP_SWING_LOW