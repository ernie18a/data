Calculation: LeadWin = LeadLen * RecMult if recommendation flag[PostLen + ExtLen] = 1, otherwise LeadLen
Calculation: PreRet = ROC(close, LeadWin)[PostLen + ExtLen + 1]
Calculation: PostRet = ROC(close, PostLen)[ExtLen + 1]
Calculation: ExtRet = ROC(close, ExtLen)[1]
Calculation: SlowRet = ROC(close, LeadWin + SlowLen)[PostLen + ExtLen + 1]
Calculation: BaseVol = SMA(volume, BaseLen)[PostLen + ExtLen + LeadWin + 1]
Calculation: LeadVolRatio = SMA(volume, LeadWin)[PostLen + ExtLen + 1] / BaseVol
Calculation: ExtVolRatio = SMA(volume, ExtLen)[1] / BaseVol
Calculation: ClusterCount = count of the last WinN events, including the current event, whose LeakClass equals the current LeakClass
Calculation: LeakClass = 0 if event flag[PostLen + ExtLen] = 0; else sign(SlowRet) if SlowLen > 0 AND abs(SlowRet) >= SlowMin AND abs(PreRet) < MoveMin AND LeadVolRatio > ElevVol; else 1 if recommendation flag[PostLen + ExtLen] = 1 AND PreRet >= MoveMin AND event sentiment[PostLen + ExtLen] >= 0; else 4 if abs(PreRet) >= MoveMin AND PreRet * PostRet < 0 AND PreRet * ExtRet > 0 AND ExtVolRatio > ElevVol; else sign(PreRet) if abs(PreRet) >= MoveMin AND event sentiment[PostLen + ExtLen] * PreRet > 0; else 2 if abs(PreRet) >= MoveMin AND event sentiment[PostLen + ExtLen] * PreRet < 0; else 3 * sign(PreRet) if abs(PreRet) >= MoveMin; else 5 if LeadVolRatio >= SpikeMult; else 0
Long: LeakClass = 1
Long: LeakClass = 3
Long: LeakClass = 4 AND PreRet > 0
Long: LeakClass = 1 AND ClusterCount >= WinK
Short: LeakClass = -1
Short: LeakClass = -3
Short: LeakClass = 4 AND PreRet < 0
Short: LeakClass = -1 AND ClusterCount >= WinK
Exit: long, event flag[PostLen + ExtLen] = 1 AND PreRet >= MoveMin AND PostRet < 0 AND ExtRet < 0 AND ExtVolRatio <= ElevVol
Exit: long, recommendation flag[PostLen + ExtLen] = 1 AND PreRet >= CoverShare * ((broker price target[PostLen + ExtLen] / close[PostLen + ExtLen + LeadWin + 1] - 1) * 100)