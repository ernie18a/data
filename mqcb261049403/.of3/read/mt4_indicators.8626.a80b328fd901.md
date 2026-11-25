Calculation: previous-period range = high(T1, last completed bar, sampled on chart bars) - low(T1, last completed bar, sampled on chart bars)
Calculation: long entry level = high(T1, last completed bar, sampled on chart bars) - previous-period range * entry retracement parameter
Calculation: long stop level = high(T1, last completed bar, sampled on chart bars) - previous-period range * stop and target 1 retracement parameter
Calculation: long target 1 = long entry level + previous-period range * stop and target 1 retracement parameter
Calculation: long target 2 = long entry level + previous-period range * target 2 extension parameter
Calculation: long target 3 = long entry level + previous-period range * target 3 extension parameter
Calculation: short entry level = low(T1, last completed bar, sampled on chart bars) + previous-period range * entry retracement parameter
Calculation: short stop level = low(T1, last completed bar, sampled on chart bars) + previous-period range * stop and target 1 retracement parameter
Calculation: short target 1 = short entry level - previous-period range * stop and target 1 retracement parameter
Calculation: short target 2 = short entry level - previous-period range * target 2 extension parameter
Calculation: short target 3 = short entry level - previous-period range * target 3 extension parameter
Calculation: rounded risk/reward(entry, target, stop) = round((round((target - entry) * price-rounding scale) / price-rounding scale) / (round((entry - stop) * price-rounding scale) / price-rounding scale) * ratio-rounding scale) / ratio-rounding scale
Calculation: unrounded risk/reward(entry, target, stop) = (round((target - entry) * price-rounding scale) / price-rounding scale) / (round((entry - stop) * price-rounding scale) / price-rounding scale)
Long: close > open(T1, bar still forming, sampled on chart bars) AND rounded risk/reward(long entry level, long target 1, long stop level) > minimum risk/reward parameter AND rounded risk/reward(long entry level, long target 2, long stop level) > minimum risk/reward parameter AND rounded risk/reward(long entry level, long target 3, long stop level) > minimum risk/reward parameter
Short: close < open(T1, bar still forming, sampled on chart bars) AND rounded risk/reward(short entry level, short target 1, short stop level) > minimum risk/reward parameter AND rounded risk/reward(short entry level, short target 2, short stop level) > minimum risk/reward parameter AND unrounded risk/reward(short entry level, short target 3, short stop level) > minimum risk/reward parameter