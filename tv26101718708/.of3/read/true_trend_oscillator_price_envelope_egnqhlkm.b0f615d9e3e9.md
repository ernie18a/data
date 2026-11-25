Calculation: Smoothed Stoch ATR = clamp(RationalQuadraticKernel(SMA(Stochastic(ATR, ATR, ATR, stochastic lookback), smoothing lookback), kernel lookback, kernel relative weighting, kernel start), 0, 100)
Calculation: Bull Trend = sqrt(RSI(RSI source, RSI lookback) × Smoothed Stoch ATR)
Calculation: Bear Trend = sqrt((100 − RSI(RSI source, RSI lookback)) × Smoothed Stoch ATR)
Long: Bull Trend > Bear Trend AND min(Bull Trend, Bear Trend) > active trend threshold
Short: Bear Trend > Bull Trend AND min(Bull Trend, Bear Trend) > active trend threshold
Long: Bull Trend > extreme threshold OR (Bull Trend ≤ extreme threshold AND Bear Trend ≤ extreme threshold AND Bull Trend > Bear Trend AND min(Bull Trend, Bear Trend) > active trend threshold)
Short: Bull Trend ≤ extreme threshold AND (Bear Trend > extreme threshold OR (Bear Trend ≤ extreme threshold AND Bear Trend > Bull Trend AND min(Bull Trend, Bear Trend) > active trend threshold))
Long: Bull Trend > Bear Trend AND min(Bull Trend, Bear Trend) > active trend threshold AND NOT (Bull Trend[1] > Bear Trend[1] AND min(Bull Trend[1], Bear Trend[1]) > active trend threshold[1])
Short: Bear Trend > Bull Trend AND min(Bull Trend, Bear Trend) > active trend threshold AND NOT (Bear Trend[1] > Bull Trend[1] AND min(Bull Trend[1], Bear Trend[1]) > active trend threshold[1])
Calculation: Bull Envelope Trigger = (envelope trigger selects trend state AND (Bull Trend > Bear Trend AND min(Bull Trend, Bear Trend) > active trend threshold OR Bull Trend > extreme threshold)) OR (envelope trigger selects extreme only AND Bull Trend > extreme threshold) OR (envelope trigger selects leader side or always on AND Bull Trend ≥ Bear Trend)
Calculation: Bear Envelope Trigger = (envelope trigger selects trend state AND (Bear Trend > Bull Trend AND min(Bull Trend, Bear Trend) > active trend threshold OR Bear Trend > extreme threshold)) OR (envelope trigger selects extreme only AND Bear Trend > extreme threshold) OR (envelope trigger selects leader side or always on AND Bear Trend > Bull Trend)
Long: Bull Envelope Trigger AND (NOT Bear Envelope Trigger OR Bull Trend ≥ Bear Trend)
Short: Bear Envelope Trigger AND NOT (Bull Envelope Trigger AND (NOT Bear Envelope Trigger OR Bull Trend ≥ Bear Trend))
Calculation: T1 Bull Trend = Bull Trend calculated on T1 bars and sampled on chart bars from the still-forming or last completed T1 bar selected by the HTF sampling setting
Calculation: T1 Bear Trend = Bear Trend calculated on T1 bars and sampled on chart bars from the still-forming or last completed T1 bar selected by the HTF sampling setting
Calculation: T1 active trend threshold = active trend threshold on T1 bars, sampled on chart bars from the still-forming or last completed T1 bar selected by the HTF sampling setting
Long: T1 Bull Trend > extreme threshold OR (T1 Bull Trend ≤ extreme threshold AND T1 Bear Trend ≤ extreme threshold AND T1 Bull Trend ≥ T1 Bear Trend AND min(T1 Bull Trend, T1 Bear Trend) > T1 active trend threshold)
Short: T1 Bull Trend ≤ extreme threshold AND (T1 Bear Trend > extreme threshold OR (T1 Bear Trend ≤ extreme threshold AND T1 Bear Trend > T1 Bull Trend AND min(T1 Bull Trend, T1 Bear Trend) > T1 active trend threshold))