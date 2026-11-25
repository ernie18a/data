Calculation: T RSI = RSI(close, RSI lookback) calculated on T bars and sampled on chart bars from the T bar still forming in realtime or the last completed T bar historically
Calculation: T RSI SMA short = SMA(T RSI, shorter lookback) calculated on T bars and sampled on chart bars from the T bar still forming in realtime or the last completed T bar historically
Calculation: T RSI SMA long = SMA(T RSI, longer lookback) calculated on T bars and sampled on chart bars from the T bar still forming in realtime or the last completed T bar historically
Calculation: T RSI slope short = LinReg(T RSI SMA short, slope lookback, 0) - LinReg(T RSI SMA short, slope lookback, 1), calculated on T bars and sampled on chart bars from the T bar still forming in realtime or the last completed T bar historically
Calculation: T RSI slope long = LinReg(T RSI SMA long, slope lookback, 0) - LinReg(T RSI SMA long, slope lookback, 1), calculated on T bars and sampled on chart bars from the T bar still forming in realtime or the last completed T bar historically
Calculation: MTF stack bias = EMA of the raw stack score using the stack smoothing lookback; for each enabled T1–T13, the row score sums +1, -1, or 0 for T RSI >= upper neutral threshold, <= lower neutral threshold, or between them; T RSI >, <, or = its previous T bar; and T RSI >, <, or = each of T RSI SMA short and T RSI SMA long. Divide the total score by the count of available comparisons and multiply by 100. T values are calculated on T bars and sampled on chart bars from the T bar still forming in realtime or the last completed T bar historically
Calculation: Pressure RSI = let half-range = (RMA(high, channel lookback) - RMA(low, channel lookback)) / 2 and midpoint = RMA(low, channel lookback) + half-range; calculate RSI((high - midpoint) / half-range, RSI lookback) and RSI((low - midpoint) / half-range, RSI lookback); choose the greater when both exceed the RSI midpoint, the lesser when both are below it, otherwise choose the value closer to the RSI midpoint, choosing the low-based value on a tie
Calculation: Upper pressure trigger = EMA(Pressure RSI[pivot offset], adaptive length), updated only when Pressure RSI[pivot offset] >= Highest(Pressure RSI, pivot window) and Pressure RSI[pivot offset] > upper neutral threshold; otherwise retain its previous value
Calculation: Lower pressure trigger = EMA(Pressure RSI[pivot offset], adaptive length), updated only when Pressure RSI[pivot offset] <= Lowest(Pressure RSI, pivot window) and Pressure RSI[pivot offset] < lower neutral threshold; otherwise retain its previous value
Long: RSI(close, RSI lookback) > upper neutral threshold
Short: RSI(close, RSI lookback) < lower neutral threshold
Long: For each enabled T1–T13, T RSI > upper neutral threshold
Short: For each enabled T1–T13, T RSI < lower neutral threshold
Long: For each enabled T1–T13, T RSI > T RSI[1]
Short: For each enabled T1–T13, T RSI < T RSI[1]
Long: For each enabled T1–T13, T RSI > T RSI SMA short
Short: For each enabled T1–T13, T RSI <= T RSI SMA short
Long: For each enabled T1–T13, T RSI > T RSI SMA long
Short: For each enabled T1–T13, T RSI <= T RSI SMA long
Long: For each enabled T1–T13, T RSI slope short > slope epsilon
Short: For each enabled T1–T13, T RSI slope short < -slope epsilon
Long: For each enabled T1–T13, T RSI slope long > slope epsilon
Short: For each enabled T1–T13, T RSI slope long < -slope epsilon
Long: MTF stack bias > 0
Short: MTF stack bias < 0
Long: MTF stack bias >= stack threshold
Short: MTF stack bias <= -stack threshold
Long: Pressure RSI > upper pressure trigger AND (stack confirmation is disabled OR MTF stack bias >= stack threshold)
Short: Pressure RSI < lower pressure trigger AND (stack confirmation is disabled OR MTF stack bias <= -stack threshold)