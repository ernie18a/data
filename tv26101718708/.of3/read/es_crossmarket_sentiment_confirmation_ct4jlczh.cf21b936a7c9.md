Calculation: Trend agreement vote = +1 if ROC(primary close requested from T1, shared ROC lookback) > 0 AND ROC(comparison close requested from T1, same shared ROC lookback) > 0; -1 if both < 0; otherwise 0. Both ROC calculations run on chart bars using T1 close values, which are forming in realtime and completed historically.
Calculation: Risk vote = +1 if ROC(risk close requested from T1, shared ROC lookback) <= -risk ROC threshold; -1 if >= risk ROC threshold; otherwise 0. ROC runs on chart bars using T1 close values, which are forming in realtime and completed historically.
Calculation: Breadth vote = +1 if SMA(breadth close requested from T1, smoothing lookback), calculated on chart bars using T1 close values that are forming in realtime and completed historically, is >= upper extreme in confirmation mode; -1 if >= upper extreme in contrarian mode; otherwise, if below upper extreme, -1 if <= lower extreme in confirmation mode or +1 if <= lower extreme in contrarian mode; otherwise +1 if > mild breadth threshold, -1 if < -mild breadth threshold, else 0.
Calculation: Composite score = Trend agreement vote + Risk vote + Breadth vote
Long: Trend agreement vote = +1 OR Risk vote = +1 OR Breadth vote = +1 OR Composite score > 0
Short: Trend agreement vote = -1 OR Risk vote = -1 OR Breadth vote = -1 OR Composite score < 0
Calculation: NQ trend vote = 1 if ROC(ES close, T1, P1) > 0 AND ROC(NQ close, T1, P1) > 0; -1 if both are < 0; otherwise 0
Calculation: VIX vote = 1 if ROC(VIX close, T1, P1) <= -P2; -1 if ROC(VIX close, T1, P1) >= P2; otherwise 0
Calculation: NYSE TICK vote = if SMA(NYSE TICK, T1, P6) >= P4 then -1 in contrarian mode, otherwise 1; else if SMA(NYSE TICK, T1, P6) <= P5 then 1 in contrarian mode, otherwise -1; else if SMA(NYSE TICK, T1, P6) > P7 then 1; else if SMA(NYSE TICK, T1, P6) < P8 then -1; otherwise 0
Calculation: Composite score = NQ trend vote + VIX vote + NYSE TICK vote
Long: NQ trend vote = 1 OR VIX vote = 1 OR NYSE TICK vote = 1 OR Composite score > 0
Short: NQ trend vote = -1 OR VIX vote = -1 OR NYSE TICK vote = -1 OR Composite score < 0