Calculation: VWAP = VWAP(hlc3, volume), anchored to the start of each day
Calculation: PP = (high_T1 + low_T1 + close_T1) / 3, using the last completed T1 bar and evaluated on chart bars
Calculation: R1 = 2 * PP - low_T1
Calculation: R2 = PP + (high_T1 - low_T1)
Calculation: R3 = high_T1 + 2 * (PP - low_T1)
Calculation: S1 = 2 * PP - high_T1
Calculation: S2 = PP - (high_T1 - low_T1)
Calculation: S3 = low_T1 - 2 * (high_T1 - PP)
Calculation: Span = R1 - S1
Calculation: R4 = R3 + Span
Calculation: R5 = R4 + Span
Calculation: S4 = S3 - Span
Calculation: S5 = S4 - Span
Calculation: EntriesToday = number of entries taken on the current day
Long: position side = flat AND time of bar >= session start AND time of bar < session end AND EntriesToday < max entries AND ((low < PP AND close > PP) OR (low < R1 AND close > R1) OR (low < R2 AND close > R2) OR (low < R3 AND close > R3) OR (low < R4 AND close > R4) OR (low < R5 AND close > R5) OR (low < S1 AND close > S1) OR (low < S2 AND close > S2) OR (low < S3 AND close > S3) OR (low < S4 AND close > S4) OR (low < S5 AND close > S5)) AND low < VWAP AND close > VWAP
Short: position side = flat AND time of bar >= session start AND time of bar < session end AND EntriesToday < max entries AND ((high > PP AND close < PP) OR (high > R1 AND close < R1) OR (high > R2 AND close < R2) OR (high > R3 AND close < R3) OR (high > R4 AND close < R4) OR (high > R5 AND close < R5) OR (high > S1 AND close < S1) OR (high > S2 AND close < S2) OR (high > S3 AND close < S3) OR (high > S4 AND close < S4) OR (high > S5 AND close < S5)) AND high > VWAP AND close < VWAP
Exit: long, close < VWAP AND close[1] < VWAP[1] AND position side[1] = long
Exit: short, close > VWAP AND close[1] > VWAP[1] AND position side[1] = short