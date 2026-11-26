Calculation: VWAP = VWAP(typical price, volume, since session start)
Calculation: VWSD = sqrt(max(0, VWAP(typical price^2, volume, since session start) - VWAP^2))
Calculation: value area high = VWAP + band multiplier * VWSD
Calculation: value area low = VWAP - band multiplier * VWSD
Long: close >= VWAP
Short: close < VWAP
Long: close > value area high
Short: close < value area low