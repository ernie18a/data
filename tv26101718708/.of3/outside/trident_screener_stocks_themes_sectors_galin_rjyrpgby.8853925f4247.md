Calculation: Relative performance over N bars = ((traded instrument close at T1 / traded instrument close N bars ago at T1) / (benchmark close at T1 / benchmark close N bars ago at T1)) - 1
Calculation: Relative strength line = traded instrument close at T1 / benchmark close at T1
Long: traded instrument close at T1 > SMA(traded instrument close, P3, T1) AND Relative performance(P1) > 0 AND Relative performance(P2) > 0
Long: traded instrument close at T1 > SMA(traded instrument close, P3, T1) AND Relative performance(P1) > 0 AND Relative performance(P2) <= 0
Long: Relative strength line >= Highest(Relative strength line, P4, T1)
Long: Relative strength line >= Highest(Relative strength line, P4, T1) AND traded instrument close at T1 < Highest(traded instrument high, P5, T1) * (1 - P6)