Calculation: NQ trend vote = 1 if ROC(ES close, T1, P1) > 0 AND ROC(NQ close, T1, P1) > 0; -1 if both are < 0; otherwise 0
Calculation: VIX vote = 1 if ROC(VIX close, T1, P1) <= -P2; -1 if ROC(VIX close, T1, P1) >= P2; otherwise 0
Calculation: NYSE TICK vote = if SMA(NYSE TICK, T1, P6) >= P4 then -1 in contrarian mode, otherwise 1; else if SMA(NYSE TICK, T1, P6) <= P5 then 1 in contrarian mode, otherwise -1; else if SMA(NYSE TICK, T1, P6) > P7 then 1; else if SMA(NYSE TICK, T1, P6) < P8 then -1; otherwise 0
Calculation: Composite score = NQ trend vote + VIX vote + NYSE TICK vote
Long: NQ trend vote = 1 OR VIX vote = 1 OR NYSE TICK vote = 1 OR Composite score > 0
Short: NQ trend vote = -1 OR VIX vote = -1 OR NYSE TICK vote = -1 OR Composite score < 0