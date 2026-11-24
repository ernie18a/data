Calculation: NewT2Bar = Time(T2, last completed bar) != Time(T2, last completed bar)[1 chart bar]
Calculation: BullGap = Low(T2 bars, last completed bar)[1] - High(T2 bars, last completed bar)[3]
Calculation: BearGap = Low(T2 bars, last completed bar)[3] - High(T2 bars, last completed bar)[1]
Calculation: Delta = sum over T3 bars in forming T1 bar of volume * s, where s = sign(close - open) if nonzero, else sign(close - previous T3 bar close)
Calculation: Imbalance = |Delta| / sum over T3 bars in forming T1 bar of volume
Calculation: POC = midpoint of the row with maximum total volume, where the forming T1 bar's high-low range so far is split into NodeRows equal rows and each T3 bar's volume is divided equally among the rows its high-low range overlaps
Long: NewT2Bar AND BullGap >= MinGap
Short: NewT2Bar AND BearGap >= MinGap
Long: Close >= Open(T1, forming bar)
Short: Close < Open(T1, forming bar)
Long: Close >= Open(T1, forming bar) AND Delta > 0 AND Imbalance >= ImbThreshold AND POC > Close AND NewT2Bar AND BullGap >= MinGap
Short: Close < Open(T1, forming bar) AND Delta < 0 AND Imbalance >= ImbThreshold AND POC > Close AND NewT2Bar AND BearGap >= MinGap