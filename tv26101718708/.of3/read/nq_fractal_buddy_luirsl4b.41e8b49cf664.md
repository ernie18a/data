Calculation: UpC2(T) = low[0] < low[1] AND close[0] > low[1] AND high[0] <= high[1], on bars of T with [0] the last completed bar
Calculation: DownC2(T) = high[0] > high[1] AND close[0] < high[1] AND low[0] >= low[1], on bars of T with [0] the last completed bar
Calculation: UpC3(T) = close[1] < open[1] AND low[0] >= low[1] AND open[0] <= MIN(open[1], close[1]) AND close[0] > MAX(open[1], close[1]) AND NOT DownC2(T) AND NOT (low[1] < low[2] AND close[1] > low[2]), on bars of T with [0] the last completed bar
Calculation: DownC3(T) = close[1] > open[1] AND high[0] <= high[1] AND open[0] >= MAX(open[1], close[1]) AND close[0] < MIN(open[1], close[1]) AND NOT UpC2(T) AND NOT (high[1] > high[2] AND close[1] < high[2]), on bars of T with [0] the last completed bar
Long: UpC2(T1) OR UpC3(T1)
Short: DownC2(T1) OR DownC3(T1)
Long: UpC2(T2) OR UpC3(T2)
Short: DownC2(T2) OR DownC3(T2)
Long: UpC2(T3) OR UpC3(T3)
Short: DownC2(T3) OR DownC3(T3)
Long: UpC2(T4) OR UpC3(T4)
Short: DownC2(T4) OR DownC3(T4)
Long: UpC2(T5) OR UpC3(T5)
Short: DownC2(T5) OR DownC3(T5)
Long: UpC2(T6) OR UpC3(T6)
Short: DownC2(T6) OR DownC3(T6)
Calculation: Dir(T) = close[0] > open[0] ? 1 : close[0] < open[0] ? -1 : 0, on bars of T with [0] the last completed bar
Calculation: RunOpenNow(T, d) = if Dir(T) = d, then MIN (d = 1) or MAX (d = -1) of open[j] over j = 0 to K-1 with Dir(T)[j] = d, where K = smallest j >= 1 with Dir(T)[j] = -d, or L+1 if none; otherwise open[0]; on bars of T with [0] the last completed bar
Calculation: RunOpenBefore(T, d) = MIN (d = 1) or MAX (d = -1) of open[j] over J1 <= j < J2 with Dir(T)[j] = d, where J1 = smallest j >= 1 with Dir(T)[j] = d, J2 = smallest j > J1 with Dir(T)[j] = -d (L+1 if none), and NA if no J1 <= L; on bars of T with [0] the last completed bar
Calculation: LevelCandidate(T) = X if ((Delivery(T)[1] = 1 AND high[0] > Extreme(T)[1]) OR (Delivery(T)[1] = -1 AND low[0] < Extreme(T)[1])) AND X is not na, otherwise Level(T)[1]; X = RunOpenNow(T, Delivery(T)[1]) if Dir(T) = Delivery(T)[1], otherwise RunOpenBefore(T, Delivery(T)[1]); on bars of T with [0] the last completed bar
Calculation: BullConfirm(T) = Delivery(T)[1] = -1 AND LevelCandidate(T) is not na AND close[0] > LevelCandidate(T), on bars of T with [0] the last completed bar
Calculation: BearConfirm(T) = Delivery(T)[1] = 1 AND LevelCandidate(T) is not na AND close[0] < LevelCandidate(T), on bars of T with [0] the last completed bar
Calculation: Delivery(T) = Delivery(T)[1] != 0 ? (BullConfirm(T) ? 1 : BearConfirm(T) ? -1 : Delivery(T)[1]) : (if bar count > W, the sign of the first nonzero Dir(T)[j] for j = 0 to H, else 0); on bars of T with [0] the last completed bar
Calculation: Extreme(T) = (BullConfirm(T) OR BearConfirm(T) OR Delivery(T)[1] = 0) ? (high[0] if Delivery(T) = 1, low[0] if Delivery(T) = -1) : (MAX(Extreme(T)[1], high[0]) if Delivery(T)[1] = 1, MIN(Extreme(T)[1], low[0]) if Delivery(T)[1] = -1); on bars of T with [0] the last completed bar
Calculation: Level(T) = (BullConfirm(T) OR BearConfirm(T) OR Delivery(T)[1] = 0) ? RunOpenNow(T, Delivery(T)) : LevelCandidate(T); on bars of T with [0] the last completed bar
Long: BullConfirm(T7)
Short: BearConfirm(T7)
Long: BullConfirm(T8)
Short: BearConfirm(T8)
Long: BullConfirm(T9)
Short: BearConfirm(T9)