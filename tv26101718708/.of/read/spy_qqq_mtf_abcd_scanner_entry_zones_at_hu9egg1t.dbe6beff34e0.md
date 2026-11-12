Calculation: Pivot = swing high/low confirmed when its high/low is the extreme among N bars on each side (N bars to the left, N bars to the right; confirmed only after the right-side bars complete)
Calculation: A, B, C = last three alternating confirmed pivots (A oldest, C newest). A new pivot of the same type as C replaces C only if more extreme (higher for a high, lower for a low). A new pivot of the opposite type shifts A<-B, B<-C, C<-new pivot
Calculation: AB = |B-A|; BC = |C-B|; retrace = BC/AB; W = ATR (Wilder) * zone factor; ATR = average true range
Calculation: BullABCD = A is pivot high AND B is pivot low AND C is pivot high AND C < A AND AB >= ATR * min-size factor AND min retrace <= retrace <= max retrace (min < max); D = C - AB
Calculation: BearABCD = A is pivot low AND B is pivot high AND C is pivot low AND C > A AND AB >= ATR * min-size factor AND min retrace <= retrace <= max retrace (min < max); D = C + AB
Long: BullABCD AND high >= D - W AND low <= D + W (entry price = D; A, C, D and W are frozen at entry for the exits)
Long: BullABCD AND high >= D - W AND low <= D + W AND close > open (confirmed variant of the same signal)
Short: BearABCD AND high >= D - W AND low <= D + W (entry price = D; A, C, D and W are frozen at entry for the exits)
Short: BearABCD AND high >= D - W AND low <= D + W AND close < open (confirmed variant of the same signal)
Exit: long, low <= D - W (stop)
Exit: long, high >= C (target 1, partial profit)
Exit: long, high >= A (target 2, final profit)
Exit: short, high >= D + W (stop)
Exit: short, low <= C (target 1, partial profit)
Exit: short, low <= A (target 2, final profit)