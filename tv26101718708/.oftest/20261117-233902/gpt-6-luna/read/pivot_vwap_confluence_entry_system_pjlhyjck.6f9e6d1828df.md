Calculation: Pivot point = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3
Calculation: Pivot resistance levels = Pivot point + (high(T1, last completed bar) - low(T1, last completed bar)) × resistance-level multiplier
Calculation: Pivot support levels = Pivot point - (high(T1, last completed bar) - low(T1, last completed bar)) × support-level multiplier
Long: within the configured session AND daily entry count below its limit AND for any pivot point, resistance level, or support level, low < level AND low < session VWAP AND close > level AND close > session VWAP
Short: within the configured session AND daily entry count below its limit AND for any pivot point, resistance level, or support level, high > level AND high > session VWAP AND close < level AND close < session VWAP
Exit: long, close < session VWAP AND close[1] < session VWAP[1]
Exit: short, close > session VWAP AND close[1] > session VWAP[1]