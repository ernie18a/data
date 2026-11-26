Calculation: B = last completed T1 bar
Calculation: R = completed T1 bar within the last n_win T1 bars that has not yet produced an entry marking
Calculation: T1Start = a T1 bar starts on this chart bar
Calculation: SessionOk = time of day of this chart bar shifted by s_gmt hours is >= s_open and < s_close, wrapping past midnight when s_open >= s_close
Calculation: GapPass = abs(open - close[1]) / ATR(chart bars, n_atr) * 100 < k_gap
Calculation: Gate = T1Start AND SessionOk AND GapPass
Calculation: SweepUp = B.high - R.high >= k_manip / 100 * ATR(T1 bars, n_atr, last completed T1 bar)
Calculation: SweepDown = R.low - B.low >= k_manip / 100 * ATR(T1 bars, n_atr, last completed T1 bar)
Calculation: Inside = R.low <= B.close AND B.close <= R.high
Calculation: CloseAbove = B.close > R.high AND B.close - R.high >= k_close / 100 * ATR(T1 bars, n_atr, last completed T1 bar)
Calculation: CloseBelow = B.close < R.low AND R.low - B.close >= k_close / 100 * ATR(T1 bars, n_atr, last completed T1 bar)
Long: Gate AND R != B AND SweepUp AND SweepDown AND B.close > B.open AND CloseAbove
Long: Gate AND R != B AND SweepUp AND SweepDown AND B.close > B.open AND Inside
Long: Gate AND R != B AND SweepUp AND NOT SweepDown AND CloseAbove
Long: Gate AND R != B AND SweepDown AND NOT SweepUp AND B.close >= R.low
Long: SessionOk AND a chart low < R.low occurred in the current T1 bar AND no chart high > R.high occurred at or before the first chart bar with low < R.low
Short: Gate AND R != B AND SweepUp AND SweepDown AND B.close < B.open AND CloseBelow
Short: Gate AND R != B AND SweepUp AND SweepDown AND B.close <= B.open AND Inside
Short: Gate AND R != B AND SweepDown AND NOT SweepUp AND CloseBelow
Short: Gate AND R != B AND SweepUp AND NOT SweepDown AND B.close <= R.high
Short: SessionOk AND a chart high > R.high occurred in the current T1 bar AND no chart low < R.low occurred at or before the first chart bar with high > R.high
Calculation: Target1 = high of the entry break bar for long, low of the entry break bar for short
Calculation: Target2 = high of the entry ref bar for long, low of the entry ref bar for short, for M2 entries only
Calculation: Stop = low of the entry ref bar for long M3+ entries, high of the entry ref bar for short M3+ entries, otherwise low of the entry break bar for long and high of the entry break bar for short
Calculation: Partial = Target1 was reached on an earlier chart bar since entry, meaning high >= Target1 for long and low <= Target1 for short
Exit: long, entry is M3 or M3+ AND (high >= Target1 OR low <= Stop)
Exit: long, entry is M2 AND ((Partial AND (high >= Target2 OR low <= Stop)) OR (NOT Partial AND ((high >= Target2 AND low > Stop) OR (low <= Stop AND NOT (high >= Target1 AND abs(open - Target1) < abs(open - Stop))))))
Exit: short, entry is M3 or M3+ AND (low <= Target1 OR high >= Stop)
Exit: short, entry is M2 AND ((Partial AND (low <= Target2 OR high >= Stop)) OR (NOT Partial AND ((low <= Target2 AND high < Stop) OR (high >= Stop AND NOT (low <= Target1 AND abs(open - Target1) < abs(open - Stop))))))