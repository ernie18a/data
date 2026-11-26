Calculation: range = high(T1, last completed bar) - low(T1, last completed bar), evaluated on chart bars
Calculation: long entry = high(T1, last completed bar) - range * entry retracement parameter
Calculation: long stop = high(T1, last completed bar) - range * stop retracement parameter, where stop retracement exceeds entry retracement
Calculation: short entry = low(T1, last completed bar) + range * entry retracement parameter
Calculation: short stop = low(T1, last completed bar) + range * stop retracement parameter
Calculation: long targets 1, 2, 3 = long entry + range * target extensions 1, 2, 3, respectively, with extensions increasing from target 1 to target 3
Calculation: short targets 1, 2, 3 = short entry - range * the same respective target extensions
Calculation: price-rounded risk/reward ratio(entry, stop, target) = round(abs(target - entry), price precision) / round(abs(entry - stop), price precision)
Calculation: rounded risk/reward ratio(entry, stop, target) = round(price-rounded risk/reward ratio(entry, stop, target), ratio precision)
Long: on each chart bar, close > open(T1, bar still forming) AND rounded risk/reward ratio(long entry, long stop, long target 1) > minimum risk/reward AND rounded risk/reward ratio(long entry, long stop, long target 2) > minimum risk/reward AND rounded risk/reward ratio(long entry, long stop, long target 3) > minimum risk/reward
Short: on each chart bar, close < open(T1, bar still forming) AND rounded risk/reward ratio(short entry, short stop, short target 1) > minimum risk/reward AND rounded risk/reward ratio(short entry, short stop, short target 2) > minimum risk/reward AND price-rounded risk/reward ratio(short entry, short stop, short target 3) > minimum risk/reward