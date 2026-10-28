Calculation: VWAP bands = VWAP ± volume-weighted standard deviation from the selected anchor period, multiplied by the band multiplier; Band 2 uses a larger multiplier than Band 1. Use the current, still-forming anchor period.
Calculation: Long target = entry price + (upper Band 2 − entry price) × target fraction
Calculation: Short target = entry price − (entry price − lower Band 2) × target fraction
Calculation: Long stop = entry price − ATR × stop multiplier
Calculation: Short stop = entry price + ATR × stop multiplier
Long: position is flat AND close ≤ lower Band 1 AND (volume filter disabled OR volume > volume SMA × volume multiplier) AND (trend filter disabled OR close > EMA) AND (time filter disabled OR bar time is within configured trading hours and outside the configured lunch period)
Short: position is flat AND close ≥ upper Band 1 AND (volume filter disabled OR volume > volume SMA × volume multiplier) AND (trend filter disabled OR close < EMA) AND (time filter disabled OR bar time is within configured trading hours and outside the configured lunch period)
Exit: long, close ≥ VWAP OR high ≥ long target OR low ≤ long stop
Exit: short, close ≤ VWAP OR low ≤ short target OR high ≥ short stop